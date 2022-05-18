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
import CoreMotion


extension CMSensorDataList: Sequence {
  public func makeIterator() -> NSFastEnumerationIterator {
      return NSFastEnumerationIterator(self)
  }
}

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
    var motionManager: CMMotionManager?
    let motionManagerSensor = CMSensorRecorder()
    var lastparsedDate: Date? = nil
    
    
    @IBAction func medicationField(_ value: NSString?) {
        medicationTextField = value! as String
    }
    @IBAction func dosageField(_ value: NSString?) {
        dosageTextField = value! as String
    }
    @IBAction func LogMedication() {
        formatter1.dateFormat = "HH:mm E, d MMM y"
        let medication = [
            "Medication": medicationTextField,
            "Dosage": dosageTextField,
            "Date": formatter1.string(from: today)
            
                        ]
        
        

        self.ref.child("users").child(user!.uid).child("medications").childByAutoId().setValue(medication) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be saved: \(error).")
            } else {
              print("Data saved successfully!")
                
                self.medicationFieldOutlet.setText("")
                self.dosageFieldOutlet.setText("")
            }
          }
        
    }
    

    override func willActivate() {
        let recorder = CMSensorRecorder()
        
        if CMSensorRecorder.isAccelerometerRecordingAvailable(){
            
        }else{
            return
        }
        let now = NSDate() as Date
        recorder.recordAccelerometer(forDuration: 5*60*60)
        
        
        //pull from database
        //for firebase would call loadFromFirebase(lastDateUploaded)
        if(lastparsedDate == nil){
            lastparsedDate = now
            return
        }
        
           
        if let list: CMSensorDataList = recorder.accelerometerData(from: lastparsedDate!, to: now){
            
            
            //Eventually make the value list
            var formattedListofVals: [String] = []
            var count = 0
                for datum in list {
                    count += 1
                    var line = "";
                         if let accdatum = datum as? CMRecordedAccelerometerData {
                             let accel = accdatum.acceleration
                             let stringx = String(accel.x)
                             let stringy = String(accel.y)
                             let stringz = String(accel.z)
                             let t = accdatum.timestamp
                             let s = String(t)
                             let date = Date.init(timeIntervalSinceNow: t)
                             let stringDate = DateFormatter().string(from: date) + ": "
                             let xAccel = "x-acceleration: " + stringx
                             let yAccel = ", y-acceleration: " + stringy
                             let zAccel = ", z-acceleration: " + stringz + "\n"
                             line = s + xAccel + yAccel + zAccel
                             formattedListofVals.append(line)
                             
                         }
                
             }
            print("this is the amount of data: ")
            print(count)
            
        
            if self.connector.send(key: "Accelerometer Data", value: formattedListofVals){
                print("Send succeeded")
                
            }
        }
            print("all data has been sent")
            lastparsedDate = now
            //update database
        
    }
    override func didDeactivate() {
        
        // This method is called when watch view controller is no longer visible
    }
    
    
}
