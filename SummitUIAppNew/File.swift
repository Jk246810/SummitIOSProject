//
//  File.swift
//  SummitUIAppNew
//
//  Created by Jamee Krzanich on 10/30/22.
//

import Foundation
import CoreBluetooth
import os.log

@available(iOS 14.0, *)
extension HomeViewController: CBCentralManagerDelegate {
    
  // called whenever the CBCentralManager instantiated too
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        if (centralManager != central) {
          display_error_Msg(Msg: "multiple central manager exists")
        }
        switch centralManager.state {
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
                num_write = 0;
                print("central.state is .poweredOn")
                scan()
            @unknown default:
                display_error_Msg(Msg: "central manager at uncovered state")
        }
    }
    func scan() {
        scanStatus = false
        centralManager.scanForPeripherals(withServices: [UartGattServiceId])
        
        status.text = "scanning"
        
        // Set the scanning duration
        let scanningDuration: TimeInterval = 10.0 // Specify the desired duration in seconds


        // Start the timer
        var scanTimer = Timer.scheduledTimer(timeInterval: scanningDuration, target: self, selector: #selector(reScan), userInfo: nil, repeats: false)
    }


    @objc func reScan() {
        if (!scanStatus) {
            stopScan();
            scan();
        }
        
    }
    
    func stopScan() {
        
        centralManager.stopScan()
        status.text = "stop scanning"
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        scanStatus = true;
      heartRatePeripheral = peripheral
      heartRatePeripheral.delegate = self
      stopScan()
        status.text = "connecting"
      centralManager.connect(heartRatePeripheral)
        
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
      display_error_Msg(Msg: "fail to connect, error: \(error.debugDescription)")
        reconnect_peripheral();
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        display_error_Msg(Msg: "Disconnect Dongle, error: \(error.debugDescription)")
        reconnect_peripheral();
        
    }
    
    func reconnect_peripheral() {
        // reconnect after 20ms delay
        let delayTime = DispatchTimeInterval.microseconds(20)
        status.text = "reconnecting"
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            if (self.heartRatePeripheral != nil) {
                self.centralManager.connect(self.heartRatePeripheral)
            } else {
                self.scan()
            }
            
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        bluetoothConnection.text = "Bluetooth connection: connected"
        status.text = "discovering services"
      heartRatePeripheral.discoverServices([UartGattServiceId])
        
    }
    
    
    func centralManagerStateToString(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "Unknown"
        case .resetting:
            return "Resetting"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "Powered Off"
        case .poweredOn:
            return "Powered On"
        @unknown default:
            return "Unknown State"
        }
    }

    
    
}

@available(iOS 14.0, *)

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
        status.text = "Discover Characteristic"
        
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
          
        }
    }
    
//    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
//      // peripheral execute this method after a failed call to write value and after the peripheral is ready for the 2nd time write.
//      print("resend write request")
//      write(value: dataToSend!, characteristic: characteristic)
//
//    }
  

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
    func peripheralStateToString(_ state: CBPeripheralState) -> String {
        switch state {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .disconnecting:
            return "Disconnecting"
        @unknown default:
            return "Unknown State"
        }
    }

    func write(value: Data, characteristic: CBCharacteristic) {
        

        if heartRatePeripheral == nil {
            scan()
            return
        }
          
        if heartRatePeripheral.state != .connected {
            reconnect_peripheral()
            return
        }


        // Based on experimentation, it's about 512 char(i.e. bytes) at a time.
        var max_bytes_per_packet_with_response = heartRatePeripheral.maximumWriteValueLength(for: CBCharacteristicWriteType.withResponse)
          
        if value.count < max_bytes_per_packet_with_response {
            heartRatePeripheral.writeValue(value, for: characteristic, type: .withResponse)
            
            
        } else {

            display_error_Msg(Msg:"message size \(value.count) > maximum length of write with response \(max_bytes_per_packet_with_response)")
        }
        
    }
    
    

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        num_write += 1
        num_write_display.text = String(num_write)
        status.text = "writing:\(num_write)"
        Error_Message.text = ""
    }
    
   
      
  /*func get_state_name(state: CBPeripheralState) -> String {
    switch state {
      case CBPeripheralState.connected:
        bluetoothConnection.text = "Bluetooth connection: connected"
        return "connected"
        break
      case CBPeripheralState.disconnected:
        bluetoothConnection.text = "Bluetooth connection: disconnected"
        return "disconnected"
      case CBPeripheralState.connecting:
        bluetoothConnection.text = "Bluetooth connection: connected"
        return "connected"
      case CBPeripheralState.disconnecting:
        bluetoothConnection.text = "Bluetooth connection: disconnected"
        return "disconnecting"
      default:
        print("peripheral connection state undefined")
        bluetoothConnection.text = "Bluetooth peripheral connection state undefined"
        return "peripheral connection state undefined"
      
    }

  }*/
}


