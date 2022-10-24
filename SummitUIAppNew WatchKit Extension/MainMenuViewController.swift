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
import UIKit

let DID_APP_ENTER_BG_WHILE_PROCESSING = "DID_APP_ENTER_BG_WHILE_PROCESSING"

class MainMenuViewController: BusableController, WKExtensionDelegate {
    var session: WKExtendedRuntimeSession!
    var accelerationArray: [String] = []
    var accByteSize = 0
    var timer = Timer()
    var motionManager: CMMotionManager?
    
    
    var didEnterBgWhileProcessing: Bool = false {
        didSet {
            // save the didEnterBgWhileProcessing value on each change
            if self.didEnterBgWhileProcessing != oldValue {
                DispatchQueue.global().async { [unowned self] in
                    UserDefaults.standard.setValue(
                        self.didEnterBgWhileProcessing,
                        forKey: DID_APP_ENTER_BG_WHILE_PROCESSING
                    )
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    // MARK: Subs
    /// are setup in the ViewController.setupBus method
    var subs: BusableController.Subs = [:]
    override var SubscriptionEvents: BusableController.Subs {
        get { return self.subs }
    }
    
    override func awake(withContext context: Any?){
        super.awake(withContext: context)
        _ = PhoneConnection.shared
        self.setupBus()
    }
    /*override func willActivate() {
        super.willActivate()
        _ = PhoneConnection.shared
        
        /*motionManager = CMMotionManager()
        locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true*/
        LocationManager.shared.requestAccess()
        self.setupBus()
        
    }*/
    
    @objc func startLogSensor(){
        
          if let data = motionManager?.accelerometerData {
              //recent  let bytes = data.description.lengthOfBytes(using: String.Encoding.utf8)
              //recent  if(accByteSize <= 460){
                  //recent   accelerationArray.append(data.description)
                  //recent   accByteSize += bytes
                  //recent }else{
                  //recent let accelerationValues = [
                  //recent "AccString": accelerationArray,
                      //recent ]
              if PhoneConnection.shared.send(key: "Acc_Data", value:[data.description] /*accelerationValues*/){
                  //recent accelerationArray = [data.description]
                  //recent    accByteSize = bytes
                     print("send succeeded")
                    print(Date())
                      
                  }else{
                       print("send failed")
                  }
             }
              
//              let accData = [
//                  "xAcc": x,
//                   "yAcc": y,
//                  "zAcc": z,
//               ] as [String : [String]]
//               accelerationArray.append(accData)
//               if PhoneConnection.shared.send(key: "Acc_Data", value: accData){
//               }else{
//                   print("send failed")
//               }
              
               //print("Have a new accelerometer stream \(accData)")
        //recent }
        
       }
    
    @IBAction func StartStreamingSelected() {
        self.motionManager = CMMotionManager()
        LocationManager.shared.requestAccess()
        if self.motionManager!.isAccelerometerAvailable {
            motionManager?.startAccelerometerUpdates()
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                               target: self,
                                              selector: #selector(self.startLogSensor),
                               userInfo: nil,
                               repeats: true)
        }else{
            print("accelerometer not available")
                    
        }
        
      
        
    }
    
    @IBAction func StopStreamingSelected() {
//        for val in accelerationArray{
//            print("here are the values \(val.values)")
        //}
       
        //locationManager?.stopUpdatingLocation()
        if self.motionManager!.isAccelerometerActive {
            self.motionManager?.stopAccelerometerUpdates()
        }
        LocationManager.shared.stopMonitoring()
        timer.invalidate()
    }
}

extension MainMenuViewController {
    func setupBus() {
        self.subs = [
            .AppEnteredBackground: self.enteredBackground(_:),
            .AppEnteredForeground: self.enteredForeground(_:),
            .LocationAuthUpdate: self.locationAccessChanged(notification:),
        ]
    }
    
    private func enteredBackground(_: Notification) {
        print("VC: App entered background")
        let gps = LocationManager.shared
        if gps.isHasAccess() && timer.isValid { gps.startMonitoring() }
        self.didEnterBgWhileProcessing = timer.isValid
        
    }
    
    private func enteredForeground(_: Notification) {
        print("VC: App entered foreground")
        let gps = LocationManager.shared
        let cache = UserDefaults.standard
        self.didEnterBgWhileProcessing = cache.bool(forKey: DID_APP_ENTER_BG_WHILE_PROCESSING)
        if !gps.isHasAccess() && self.didEnterBgWhileProcessing {
            print("something went terribly wrong")
        } else if gps.state == .Monitoring {
            gps.startMonitoring()
        }
    }
    
    private func locationAccessChanged(notification: Notification) {
        let info = notification.userInfo
        if let state = info?["status"] as? LocationManager.LocationAuthStatus {
            print(state)
        }
    }
    
}


