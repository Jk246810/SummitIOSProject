//
//  OptionsViewController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 6/29/22.
//

import Foundation
import WatchKit
import CoreMotion
import CoreLocation

class MainMenuViewController: WKInterfaceController, WKExtensionDelegate, CLLocationManagerDelegate {
    var session: WKExtendedRuntimeSession!
    //var backgroundTask = BackgroundTask()
    //var accelerationArray: [[String : String]] = []
    var timer = Timer()
    var motionManager: CMMotionManager?
    
    var locationManager: CLLocationManager?
    
    override func willActivate() {
        super.willActivate()
        _ = PhoneConnection.shared
        
        locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
    }
    
    @objc func startLogSensor(){
          if let data = motionManager?.accelerometerData {
              print(data)
//              let accData = [
//                  "xAcc": x,
//                   "yAcc": y,
//                  "zAcc": z,
//               ] as [String : String]
//               accelerationArray.append(accData)
//               if PhoneConnection.shared.send(key: "Acc_Data", value: accData){
//               }else{
//                   print("send failed")
//               }
              
               //print("Have a new accelerometer stream \(accData)")
           }
        
       }
    
    @IBAction func StartStreamingSelected() {
       // backgroundTask.startBackgroundTask()
        self.motionManager = CMMotionManager()
            if self.motionManager!.isAccelerometerAvailable {
                self.motionManager?.startAccelerometerUpdates()
                if (locationManager?.authorizationStatus == .authorizedAlways || locationManager?.authorizationStatus == .authorizedWhenInUse){
                    locationManager?.startUpdatingLocation()
                
                self.timer = Timer.scheduledTimer(timeInterval: 1.0 / 5,
                                       target: self,
                                                      selector: #selector(self.startLogSensor),
                                       userInfo: nil,
                                       repeats: true)
                }
        }else{
            print("accelerometer not available")
                    
        }
        
    }
    
    @IBAction func StopStreamingSelected() {
        //backgroundTask.stopBackgroundTask()
//        for val in accelerationArray{
//            print("here are the values \(val.values)")
        //}
        locationManager?.stopUpdatingLocation()
        if self.motionManager!.isAccelerometerActive {
                   self.motionManager?.stopAccelerometerUpdates()
               }
               timer.invalidate()
    }
}
