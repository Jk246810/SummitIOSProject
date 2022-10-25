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
import CoreBluetooth

let UartGattServiceId = CBUUID(string: "0000FFF0-0000-1000-8000-00805f9b34fb")
let UartGattCharacteristicReceiveId = CBUUID(string: "0000FFF1-0000-1000-8000-00805f9b34fb")
let UartGattCharacteristicSendId = CBUUID(string: "0000FFF2-0000-1000-8000-00805f9b34fb")

class HomeViewController: UIViewController, WCSessionDelegate {
    var char_external_write: CBCharacteristic?
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    var dataToSend = "test_string".data(using: .ascii)
    
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
        self.CTMStatus.tintColor = UIColor.red
        self.INSStatus.tintColor = UIColor.red
        self.TabletStatus.tintColor = UIColor.red
        if((user) != nil){
            db = Firestore.firestore()
            registerAPNSwithFirebase()
            setUpWatchConnection()
            enableBatteryListener()
        }
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
    
    
    
    func registerAPNSwithFirebase(){
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("Remote FCM registration token: \(token)")
                Firestore.firestore().collection("Users_Collection").document(Auth.auth().currentUser!.uid).setData([ "FCM_token": token ], merge: true)
            }
        }
    }
    
    func setUpWatchConnection(){
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    func enableBatteryListener(){
        db.collection("Users_Collection").document(user!.uid).collection("AtHome_Collection").document("Battery_Status_Document").addSnapshotListener{ documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                self.CTMStatus.tintColor = UIColor.red
                self.INSStatus.tintColor = UIColor.red
                self.TabletStatus.tintColor = UIColor.red
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            guard let CTMbattery = data["CTM_Low_Battery"] as? Int else{
                return
            }
            guard let INSbattery = data["INS_Low_Battery"] as? Int else{
                return
            }
            guard let computerbattery = data["Computer_Low_Battery"] as? Int else{
                return
            }
            self.handleBatteryStatus(ctmVal: CTMbattery, insVal: INSbattery, surfaceVal: computerbattery)
            
        }
    }
        
    func batteryStatus(val: Int, image: UIImageView){
        switch val{
        case 0:
            image.tintColor = UIColor.red
        case 1:
            image.tintColor = UIColor.yellow
        case 2:
            image.tintColor = UIColor.green
        default:
            image.tintColor = UIColor.gray
        }
    }
    
    func handleBatteryStatus(ctmVal: Int, insVal: Int, surfaceVal: Int){
        batteryStatus(val: ctmVal, image: CTMStatus)
        batteryStatus(val: insVal, image: INSStatus)
        batteryStatus(val: surfaceVal, image: TabletStatus)
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
            if let medOptionData = message["NormalMedication"] as? [String: String]{
                Firestore.firestore().collection("Users_Collection").document(self.user!.uid).collection("Medications").document().setData([
                    "Notes": "Normal Medication Schedule",
                    "Date" : medOptionData["Date"] as Any
                    ])
                print("successfully stored")
            }
            if let medData = message["Medication"] as? [String:String]{
                Firestore.firestore().collection("Users_Collection").document(self.user!.uid).collection("Medications").document().setData([
                    "Medication": medData["Medication"] as Any,
                    "Dosage":  medData["Dosage"] as Any,
                    "Date":  medData["Date"] as Any
                ])
            }
            if let medData = message["Acc_Data"] as? [String:[String]]{
                let accArray = medData["AccString"]!
                for acc in accArray{
                    if let char_external_write2 = self.char_external_write {
                        self.write(value: acc.data(using: .utf8)!, characteristic: char_external_write2)
                        print("sent data to bluetooth")
                        print(Date())
                       
                    }
                    
                    
                }
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

extension HomeViewController: CBCentralManagerDelegate {
  // called whenever the CBCentralManager instantiated too
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .unknown:
      print("central.state is .unknown")
    case .resetting:
      print("central.state is .resetting")
    case .unsupported:
      print("central.state is .unsupported")
    case .unauthorized:
      print("central.state is .unauthorized")
    case .poweredOff:
      print("central.state is .poweredOff")
    case .poweredOn:
      print("central.state is .poweredOn")
      centralManager.scanForPeripherals(withServices: [UartGattServiceId])
    }
  }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
      print(peripheral)
      heartRatePeripheral = peripheral
      heartRatePeripheral.delegate = self
      centralManager.stopScan()
      centralManager.connect(heartRatePeripheral)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
      print("file to connect, error: \(error.debugDescription)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
      heartRatePeripheral = peripheral // has to store peripheral expicily otherwise it will be disposed and break the pending connection
      centralManager.connect(heartRatePeripheral)
      print("Disconnect handler activated")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected!")
      heartRatePeripheral.discoverServices([UartGattServiceId])
    }
}

extension HomeViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    for service in services {
      print(service)
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else { return }
    
    for characteristic in characteristics {
      print("newly discovered characteristic:")
      print(characteristic)

      if characteristic.properties.contains(.read) {
        print("\(characteristic.uuid): properties contains .read")
        peripheral.readValue(for: characteristic)
      }
      if characteristic.properties.contains(.notify) {
        print("\(characteristic.uuid): properties contains .notify")
        //peripheral.setNotifyValue(true, for: characteristic)
      }
      if characteristic.properties.contains(.write) {
        print("\(characteristic.uuid): properties contains .write")
        if characteristic.uuid.isEqual(UartGattCharacteristicSendId) {
          char_external_write = characteristic
          write(value: dataToSend!, characteristic: characteristic)
        }
      }
      func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        // peripheral execute this method after a failed call to write value and after the peripheral is ready for the 2nd time write.
        print("resend write request")
        write(value: dataToSend!, characteristic: characteristic)
        
      }
    }
  }
  

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    switch characteristic.uuid {
    case UartGattCharacteristicSendId:
      print("do nothing when sent charcteristic value updates")
      //centralManager.cancelPeripheralConnection(peripheral)
      //var a = centralManager.scanForPeripherals(withServices: [UartGattServiceId])
      
      if let error = error {
        print("ERROR: write unsuccessful")
        print(error.localizedDescription)
        
        centralManager.scanForPeripherals(withServices: [UartGattServiceId])
        
        return
      }
//      let bodySensorLocation = Process_Characteristics(from: characteristic)
//      bodySensorLocationLabel.text = bodySensorLocation
    case UartGattCharacteristicReceiveId:
      print(characteristic.value ?? "no value") // this will be a value where you need to write function to interpret
    
//      let bpm = heartRate(from: characteristic)
//      onHeartRateReceived(bpm)
    default:
      print("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
  }
  
  func write(value: Data, characteristic: CBCharacteristic) {
    var a = heartRatePeripheral;
    if heartRatePeripheral == nil {
      centralManager.scanForPeripherals(withServices: [UartGattServiceId])
    }
    // Yet to be tested
    
    /*
    if disconnect {
      centralManager.connect(heartRatePeripheral)
      print("waiting for reconnect before write")
    }
     */
    
    // In experience, it's about 239 char at a time.
    var maximum_bytes_per_packet = heartRatePeripheral.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse)
    
    
    
    //let mutRawPointer = UnsafeMutableRawPointer(mutating: UnsafePointer<UInt8>)
    
    if heartRatePeripheral!.canSendWriteWithoutResponse {
      
      if value.count < maximum_bytes_per_packet {
        heartRatePeripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        
        print("\(characteristic.uuid)\n")
        
      } else {
        print("message size \(value.count) is not smaller than maximum length \(maximum_bytes_per_packet)")
      }
      
    }
    else {
      print("can't write without response. Wrote with response");
      if value.count < maximum_bytes_per_packet {
        heartRatePeripheral.writeValue(value, for: characteristic, type: .withResponse)
        
        print("\(characteristic.uuid)\n")
        
      } else {
        print("message size \(value.count) is not smaller than maximum length \(maximum_bytes_per_packet)")
      }
    }
    
  }
  
  
  
  
/*
  private func Process_Characteristics(from characteristic: CBCharacteristic) -> String {
    if let characteristicData = characteristic.value {
      return "method incomplete"
    } else { return "Error" }
//
//    switch byte {
//    case 0: return "Other"
//    case 1: return "Chest"
//    case 2: return "Wrist"
//    case 3: return "Finger"
//    case 4: return "Hand"
//    case 5: return "Ear Lobe"
//    case 6: return "Foot"
//    default:
//      return "Reserved for future use"
//    }
  }

  private func heartRate(from characteristic: CBCharacteristic) -> Int {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
    // The heart rate mesurement is in the 2nd, or in the 2nd and 3rd bytes, i.e. one one or in two bytes
    // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
    let firstBitValue = byteArray[0] & 0x01
    if firstBitValue == 0 {
      // Heart Rate Value Format is in the 2nd byte
      return Int(byteArray[1])
    } else {
      // Heart Rate Value Format is in the 2nd and 3rd bytes
      return (Int(byteArray[1]) << 8) + Int(byteArray[2])
    }
  }
 */
}

