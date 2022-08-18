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

class HomeViewController: UIViewController, WCSessionDelegate {
    var user = Auth.auth().currentUser
    var db: Firestore!
   
    @IBOutlet weak var CTMStatus: UIImageView!
    @IBOutlet weak var CTMBattery: UILabel!
    
    @IBOutlet weak var INSStatus: UIImageView!
    @IBOutlet weak var INSBattery: UILabel!
    
    @IBOutlet weak var TabletStatus: UIImageView!
    @IBOutlet weak var TabletBattery: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if((user) != nil){
            db = Firestore.firestore()
            registerAPNSwithFirebase()
            setUpWatchConnection()
            enableBatteryListener()
        }else{
           
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
            }
            if let medData = message["Medication"] as? [String:String]{
                Firestore.firestore().collection("Users_Collection").document(self.user!.uid).collection("Medications").document().setData([
                    "Medication": medData["Medication"] as Any,
                    "Dosage":  medData["Dosage"] as Any,
                    "Date":  medData["Date"] as Any
                ])
            }
            if let userFeedback = message["Feedback"] as? [String:Any]{
                Firestore.firestore().collection("Users_Collection").document(self.user!.uid).collection("Feedback").document().setData([
                    "Rating": userFeedback["Rating"]as! Int,
                    "Notes":  userFeedback["Message"] as! String
                ])
            }
        }
    }
        
}
