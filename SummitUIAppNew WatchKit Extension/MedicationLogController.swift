//
//  MedicationLogController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 1/11/22.
//

import WatchKit
import Foundation
import FirebaseAuth


class MedicationLogController:
    WKInterfaceController {
    
    @IBOutlet weak var medicationFieldOutlet: WKInterfaceTextField!
    
    @IBOutlet weak var dosageFieldOutlet: WKInterfaceTextField!
    
    var user = Auth.auth().currentUser
    var medicationTextField="Livadopa"
    var dosageTextField=""
    
    let today = Date()
    let formatter1 = DateFormatter()
    
    
    @IBAction func medicationField(_ value: NSString?) {
        medicationTextField = (value ?? "Livadopa") as String
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
        if PhoneConnection.shared.send(key: "Medication", value: medication){
            print("Send succeeded")
        }else{
            print("send failed")
        }
       
        self.medicationFieldOutlet.setText("Livadopa")
        self.dosageFieldOutlet.setText("")
    }
    
}
