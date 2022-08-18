//
//  MedicationOptionViewController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 8/17/22.
//

import Foundation
import WatchKit

class MedicationOptionViewController: WKInterfaceController {
    let today = Date()
    let formatter1 = DateFormatter()
    
    @IBAction func logNormalMeds() {
        formatter1.dateFormat = "HH:mm E, d MMM y"
        
        let medication = [
            "Date": formatter1.string(from: today)
        ]
        if PhoneConnection.shared.send(key: "NormalMedication", value: medication){
            successfullySent()
            
        }else{
            failedToSend()
        }
    }
    
    func successfullySent(){
        let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default) {
                print("Ok")
            }
            presentAlert(withTitle: "Success!", message: "Your medication was successfully logged", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
    
    func failedToSend(){
        let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default) {
                print("Ok")
            }
            presentAlert(withTitle: "Cannot reach phone", message: "Please check to ensure you are connected to your Phone ", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
    
}
