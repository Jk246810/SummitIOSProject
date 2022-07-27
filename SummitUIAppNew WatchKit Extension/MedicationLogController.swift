//
//  MedicationLogController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 1/11/22.
//

import WatchKit
import Foundation
import FirebaseDatabase
import FirebaseAuth


class MedicationLogController:
    WKInterfaceController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var medicationFieldOutlet: WKInterfaceTextField!
    
    @IBOutlet weak var dosageFieldOutlet: WKInterfaceTextField!
    
    var user = Auth.auth().currentUser
    var medicationTextField=""
    var dosageTextField=""
    
    let today = Date()
    let formatter1 = DateFormatter()
    
    var connector = PhoneConnection()
    var session: WKExtendedRuntimeSession!
    
    var lastparsedDate: Date? = nil
    
    
    @IBAction func medicationField(_ value: NSString?) {
        medicationTextField = (value ?? " ") as String
    }
    @IBAction func dosageField(_ value: NSString?) {
        dosageTextField = (value ?? " ") as String
    }
    @IBAction func LogMedication() {
        formatter1.dateFormat = "HH:mm E, d MMM y"
        let medication = [
            "Medication": medicationTextField,
            "Dosage": dosageTextField,
            "Date": formatter1.string(from: today)
            
                        ]
        
        if self.connector.send(key: "Medication", value: medication){
            print("Send succeeded")
        }else{
            print("send failed")
        }
        print("current user")
        print(user?.uid ?? "")
       
        self.medicationFieldOutlet.setText("")
        self.dosageFieldOutlet.setText("")
    }
    
}
