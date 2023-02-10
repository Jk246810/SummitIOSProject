//
//  HomeView.swift
//  SummitUIAppNew
//
//  Created by Jamee Krzanich on 11/17/21.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import WatchConnectivity
import UserNotifications
import FirebaseMessaging
import CoreBluetooth
import os.log

let UartGattServiceId = CBUUID(string: "0000FFF0-0000-1000-8000-00805f9b34fb")
let UartGattCharacteristicReceiveId = CBUUID(string: "0000FFF1-0000-1000-8000-00805f9b34fb")
let UartGattCharacteristicSendId = CBUUID(string: "0000FFF2-0000-1000-8000-00805f9b34fb")

@available(iOS 14.0, *)
class HomeViewController: UIViewController, WCSessionDelegate {
    var char_external_write: CBCharacteristic?
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    var dataToSend = "test_string".data(using: .ascii)
    
    private let logger = Logger(
      subsystem: "IOS CPSL", category: "BLE"
    )
    
    var user = Auth.auth().currentUser
    var db: Firestore!
   
    @IBOutlet weak var CTMStatus: UIImageView!
    @IBOutlet weak var CTMBattery: UILabel!
    
    @IBOutlet weak var INSStatus: UIImageView!
    @IBOutlet weak var INSBattery: UILabel!
    
    @IBOutlet weak var TabletStatus: UIImageView!
    @IBOutlet weak var TabletBattery: UILabel!
    
    @IBOutlet weak var bluetoothConnection: UILabel!
    
    @IBOutlet weak var CTMNumberBattery: UILabel!
    
    @IBOutlet weak var TabletNumberBattery: UILabel!
    
    @IBOutlet weak var INSNumberBattery: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CTMStatus.tintColor = UIColor.red
        self.INSStatus.tintColor = UIColor.red
        self.TabletStatus.tintColor = UIColor.red
        if((user) != nil){
            db = Firestore.firestore()
            registerAPNSwithFirebase()
            setUpWatchConnection()
            enableBatteryListener()
            enableBatteryLevel()
        }
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        
    }
    
    
    @IBAction func signOutClicked(_ sender: Any) {
        let firebaseAuth = Auth.auth()
      do {
        try firebaseAuth.signOut()
          let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
          self.present(viewController, animated: true, completion: nil)
      } catch let signOutError as NSError {
        print("Error signing out: %@", signOutError)
      }
        
    }
    
    
    
    func registerAPNSwithFirebase(){
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("Remote FCM registration token: \(token)")
                Firestore.firestore().collection("Users_Collection").document(Auth.auth().currentUser!.uid).setData([ "FCM_token": token ], merge: true)
            }
        }
    }
    
    func setUpWatchConnection(){
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    func enableBatteryListener(){
        db.collection("Users_Collection").document(user!.uid).collection("AtHome_Collection").document("Battery_Status_Document").addSnapshotListener{ documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                self.CTMStatus.tintColor = UIColor.red
                self.INSStatus.tintColor = UIColor.red
                self.TabletStatus.tintColor = UIColor.red
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            guard let CTMbattery = data["CTM_Low_Battery"] as? Int else{
                return
            }
            guard let INSbattery = data["INS_Low_Battery"] as? Int else{
                return
            }
            guard let computerbattery = data["Computer_Low_Battery"] as? Int else{
                return
            }
            self.handleBatteryStatus(ctmVal: CTMbattery, insVal: INSbattery, surfaceVal: computerbattery)
            
        }
    }
        
    func batteryStatus(val: Int, image: UIImageView){
        switch val{
        case 0:
            image.tintColor = UIColor.red
        case 1:
            image.tintColor = UIColor.yellow
        case 2:
            image.tintColor = UIColor.green
        default:
            image.tintColor = UIColor.gray
        }
    }
    
    func handleBatteryStatus(ctmVal: Int, insVal: Int, surfaceVal: Int){
        batteryStatus(val: ctmVal, image: CTMStatus)
        batteryStatus(val: insVal, image: INSStatus)
        batteryStatus(val: surfaceVal, image: TabletStatus)
    }
    
    func enableBatteryLevel(){
        db.collection("Users_Collection").document(user!.uid).collection("AtHome_Collection").document("Battery_Level_Document").addSnapshotListener{ documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                self.CTMNumberBattery.text = "NA"
                self.INSNumberBattery.text = "NA"
                self.TabletNumberBattery.text = "NA"
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            guard let CTMbattery = data["CTM_Battery_Level"] as? Int else{
                return
            }
            guard let INSbattery = data["INS_Battery_Level"] as? Int else{
                return
            }
            guard let computerbattery = data["Computer_Battery_Level"] as? Int else{
                return
            }
            self.handleNumberStatus(ctmVal: CTMbattery, insVal: INSbattery, surfaceVal: computerbattery)
            
        }
    }
    
    func handleNumberStatus(ctmVal: Int, insVal: Int, surfaceVal: Int){
        CTMNumberBattery.text = String(ctmVal)
        INSNumberBattery.text = String(insVal)
        TabletNumberBattery.text = String(surfaceVal)
    }
    
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith state = \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {

        DispatchQueue.main.async {
            if let medOptionData = message["NormalMedication"] as? [String: String]{
                Firestore.firestore().collection("Users_Collection").document(self.user!.uid).collection("Medications").document().setData([
                    "Notes": "Normal Medication Schedule",
                    "Date" : medOptionData["Date"] as Any
                    ])
                print("successfully stored")
            }
            if let medData = message["Medication"] as? [String:String]{
                Firestore.firestore().collection("Users_Collection").document(self.user!.uid).collection("Medications").document().setData([
                    "Medication": medData["Medication"] as Any,
                    "Dosage":  medData["Dosage"] as Any,
                    "Date":  medData["Date"] as Any
                ])
            }
            if let medData = message["Acc_Data"] as? [String:String]{
                let accArray = medData["AccString"]!
                //this is the bluetooth code, took out to test firebase implementation
                    if let char_external_write2 = self.char_external_write {
                        self.write(raw_value: accArray.data(using: .utf8)!, characteristic: char_external_write2)
                       
                    }
                //this is the code to upload to firestore
               /* print("Here is the following value\(accArray)")
                Firestore.firestore().collection("Users_Collection").document(self.user!.uid).collection("Acceleration Data").document().setData([
                    "AccelerationString": accArray as Any
                ])*/
               
            }
            if let userFeedback = message["Feedback"] as? [String:Any]{
                Firestore.firestore().collection("Users_Collection").document(self.user!.uid).collection("Feedback").document().setData([
                    "Good": userFeedback["Good"]as Any,
                    "Notes":  userFeedback["Message"] as! String
                ])
            }
        }
    }
        
}

