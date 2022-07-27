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
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("Remote FCM registration token: \(token)")
              Firestore.firestore().collection("Users_Collection").document(Auth.auth().currentUser!.uid).setData([ "FCM_token": token ], merge: true)
          }
        }
        print("current User: \(String(describing: user?.uid))")
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        
        db = Firestore.firestore()
        
        
        db.collection("Users_Collection").document(user!.uid).collection("AtHome_Collection").document("Battery_Status_Document").addSnapshotListener { documentSnapshot, error in
            print("a value changed")
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                print("Document data was empty.")
                return
              }
            
            guard let CTMbattery = data["CTM_Low_Battery"] as? Bool else {
                return
            }
            guard let INSbattery = data["INS_Low_Battery"] as? Bool else{
                return
            }
            guard let computerbattery = data["Computer_Low_Battery"] as? Bool else{
                return
            }
            
            if(CTMbattery){
                self.CTMStatus.tintColor = UIColor.red
            }else{
                self.CTMStatus.tintColor = UIColor.green
            }
            if(INSbattery){
                self.INSStatus.tintColor = UIColor.red
            }else{
                self.INSStatus.tintColor = UIColor.green
            }
            if(computerbattery){
                self.TabletStatus.tintColor = UIColor.red
            }else{
                self.TabletStatus.tintColor = UIColor.green
            }
            
            }
        //need to deactiate listener when app not in use


    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        let content = UNMutableNotificationContent()
        content.title = "LOW BATTERY"
        content.body = "Connect devices to power source immediately"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
               print("the following request did not work")
              // Handle any errors.
           }
        }
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
            if let medData = message["Medication"] as? [String:String]{
                let mess = "medication data accumulated: " + String(medData.count)
                print(mess)
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
