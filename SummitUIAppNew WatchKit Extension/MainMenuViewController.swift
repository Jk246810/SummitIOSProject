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

var INDEX = 0;

class MainMenuViewController: BusableController, WKExtensionDelegate {
    var session: WKExtendedRuntimeSession!
    
    @IBOutlet weak var streamingButton: WKInterfaceButton!
    
    var accelerationArray: [String] = []
    var accByteSize = 0
    var accelerometerString = ""
    
    var differenceArray: [Int] = []
    
    var testTimer = Timer()
    var count = 0
    
    var timer = Timer()
    var motionManager: CMMotionManager?
    
    var prevDate: String? = nil
    var currDate: String? = nil

    
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
        
        //streamingButton.setEnabled(false)
        //streamingButton.setHidden(true)
        
        //added to fix edge case
        
        
        self.setupBus()
        if(timer.isValid){
            streamingButton.setBackgroundImage(UIImage(systemName: "pause.circle"))
        }else{
            streamingButton.setBackgroundImage(UIImage(systemName: "play.circle"))
        }
    }
    
    func get_time_stamp() -> String {
        var date = Date()
        if #available(watchOSApplicationExtension 8, *) {
            date = Date.now
        } else {
            print("watch os 8 not available")

        }
        INDEX+=1
        let ms_since_1970 = date.timeIntervalSince1970
        let milisec = Int64(ms_since_1970*1000)%1000
        let Datefrom1970 = Date(timeIntervalSince1970: Double(Int(ms_since_1970)))
        
        let format = DateFormatter()
        format.dateFormat = "HH:mm:ss"
        var stringMiliSec = String(milisec)
        let milisecFormat = "FFF"
       
        while(stringMiliSec.count<milisecFormat.count){
                stringMiliSec = "0"+stringMiliSec
        }
        
        var timestamp = format.string(from: Datefrom1970) + ":" + stringMiliSec
        
        currDate = timestamp
        //timestamp = String(INDEX) + timestamp
        return timestamp
        
        
    }
    
    func convertStringtoMili(dateString : String) -> Int{
        var data_string_list = dateString.split(separator: ":")
        var hr_ms = Int(data_string_list[0])!*3600*1000
        var min_ms = Int(data_string_list[1])!*60*1000
        var sec_ms = Int(data_string_list[2])!*1000
        var ms_ms = data_string_list[3]
        var total_sec = Int(hr_ms) + Int(min_ms) + Int(sec_ms) + Int(ms_ms)!
        return total_sec
    }
    
    func getServerTimeStamp() -> String {
        let url = URL(string: "http://www.google.com")
        var returnString = ""
        URLSession.shared.dataTask(with: url!) { _, response, _ in
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse?.statusCode)
                if let stringDate = httpResponse?.allHeaderFields["Date"] as? String {
                   print(httpResponse)
                }
            }.resume()
        
        return returnString

    }
           
    
    
    
    
    @objc func startLogSensor(){
        
        if let data = motionManager?.deviceMotion/*motionManager?.accelerometerData*/ {
            let accX = data.userAcceleration.x
            let accY = data.userAcceleration.y
            let accZ = data.userAcceleration.z
              
              let accXEdited = Double(floor(1000*accX)/1000)
              let accYEdited = Double(floor(1000*accY)/1000)
              
              
              var accZEdited = Double(floor(1000*accZ)/1000)
              
              
              let accDate = get_time_stamp()

            
              
              let newString = "\(accDate);A(\(accXEdited),\(accYEdited),\(accZEdited))|"
              count += 1
             let bytes = newString.lengthOfBytes(using: String.Encoding.utf8)
              accByteSize += bytes
               if(accByteSize <= 510){
                  
                  accelerometerString = accelerometerString + newString
                   if(prevDate != nil){
                       var prevMiliseconds = convertStringtoMili(dateString: prevDate!)
                       var currMiliseconds = convertStringtoMili(dateString: currDate!)
                       var diff = currMiliseconds - prevMiliseconds
                       differenceArray.append(diff)
                       
                      
                   }
                   prevDate = currDate
                  
                }else{
                    
                  
                  let accelerationValues = [
                  "AccString": accelerometerString,
                      ]
              if PhoneConnection.shared.send(key: "Acc_Data", value:accelerationValues){
                  print("Here is the accelerometer String: \(accelerometerString)")
                  accelerometerString = newString
                  accByteSize = bytes
                  prevDate = currDate
                    
                      
                }else{
                       print("send failed")
                  }
             }
              
          }
        
       }
    
    
    @IBAction func StartStreamingSelected() {
        if(!timer.isValid){
        self.motionManager = CMMotionManager()
        LocationManager.shared.requestAccess()
        if self.motionManager!.isDeviceMotionAvailable {
            streamingButton.setBackgroundImage(UIImage(systemName: "pause.circle"))
            motionManager?.startDeviceMotionUpdates()
            motionManager?.deviceMotionUpdateInterval = 1.0/35
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0/35,
                               target: self,
                                              selector: #selector(self.startLogSensor),
                               userInfo: nil,
                               repeats: true)
            
            
        }else{
            accelerometerFailed()
                    
        }
        }else{
            /*if self.motionManager!.isAccelerometerActive {
                self.motionManager?.stopAccelerometerUpdates()
            }*/
            if self.motionManager!.isDeviceMotionActive{
                self.motionManager?.stopDeviceMotionUpdates()
            }
            timer.invalidate()
            LocationManager.shared.stopMonitoring()
            print("status of monitoring: \(LocationManager.shared.state != .Monitoring)")
            //print(differenceArray)
            differenceArray = []
            streamingButton.setBackgroundImage(UIImage(systemName: "play.circle"))
        }
        
    }
    
    /*@IBAction func SignOutClicked() {
        let firebaseAuth = Firebase.Auth.auth()
        do {
          try firebaseAuth.signOut()
            self.pushController(withName: "InterfaceController", context: nil)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }*/
    
 
    
}

extension MainMenuViewController {
    func setupBus() {
        self.subs = [
            .AppEnteredBackground: self.enteredBackground(_:),
            .AppEnteredForeground: self.enteredForeground(_:),
            .LocationAuthUpdate: self.locationAccessChanged(notification:)
        ]
    }
    
    private func enteredBackground(_: Notification) {
        print("VC: App entered background")
        let gps = LocationManager.shared
        if gps.isHasAccess() && timer.isValid /*&& gps.state != .Monitoring*/{
            gps.startMonitoring() }
        self.didEnterBgWhileProcessing = timer.isValid
        
    }
    
    private func enteredForeground(_: Notification) {
        print("VC: App entered foreground")
        let gps = LocationManager.shared
        let cache = UserDefaults.standard
        self.didEnterBgWhileProcessing = cache.bool(forKey: DID_APP_ENTER_BG_WHILE_PROCESSING)
        if !gps.isHasAccess() && self.didEnterBgWhileProcessing {
            print("something went terribly wrong")
        }
        else if gps.state == .Monitoring {
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

extension MainMenuViewController{
    func accelerometerFailed(){
        let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default) {
                print("Ok")
            }
            presentAlert(withTitle: "Cannot Start Accelerometer", message: "Cannot access accelerometer metrics at this time", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
}

extension MainMenuViewController{
    @objc func testingWatch(){
        print("here is the frequency transmitted \(count/10)")
    }
}


