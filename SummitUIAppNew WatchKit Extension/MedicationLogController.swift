//
//  MedicationLogController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 1/11/22.
//

import WatchKit
import Foundation
//import FirebaseAuth


class MedicationLogController:
    WKInterfaceController {
    
    @IBOutlet weak var medicationFieldOutlet: WKInterfaceTextField!
    
    @IBOutlet weak var dosageFieldOutlet: WKInterfaceTextField!
    
   // lazy var user = Auth.auth().currentUser
    var medicationTextField=""
    var dosageTextField=""
    
    let today = Date()
    let formatter1 = DateFormatter()
    

    
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
        if PhoneConnection.shared.send(key: "Medication", value: medication){
            successfullySent()
        }else{
            let action = WKAlertAction(title: "Send Failed", style: WKAlertActionStyle.default) {
                    print("Ok")
                }
                presentAlert(withTitle: "Cannot reach phone", message: "Please check to ensure you are connected to your Phone ", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
           
        }
       
        self.medicationFieldOutlet.setText("")
        self.dosageFieldOutlet.setText("")
    }
    
    func successfullySent(){
        let action = WKAlertAction(title: "Ok", style: WKAlertActionStyle.default) {
                print("Ok")
            }
            presentAlert(withTitle: "Success!", message: "Your medication was successfully logged", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
    
}
