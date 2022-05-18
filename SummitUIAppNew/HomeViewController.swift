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
import CoreMotion

class HomeViewController: UIViewController, WCSessionDelegate {
    var user = Auth.auth().currentUser
    var db: Firestore!
    var recentlyUploadedData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        
        db = Firestore.firestore()
        db.collection("Users_Collection").document(user!.uid).collection("Program_Collection").document("Listeners_Document")
            .addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                print("Document data was empty.")
                return
              }
                print("Current data: \(data)")
            }
        
        db.collection("data").document("test").setData(["accelerometer readings": recentlyUploadedData]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
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
            if let accAllData = message["Accelerometer Data"] as? [String] {
                
                for dataVal in accAllData{
                    self.recentlyUploadedData.append(dataVal)
                }
                //self.dataReceivedLabel.text = "Data Received"
                let format = DateFormatter()
                format.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                //self.timeStampLabel.text = format.string(from: Date())
            }
            
        }
    }
}
