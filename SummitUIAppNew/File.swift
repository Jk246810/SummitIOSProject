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
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .unknown:
      //print("central.state is .unknown")
      break
    case .resetting:
      //print("central.state is .resetting")
      break
    case .unsupported:
      //print("central.state is .unsupported")
      break
    case .unauthorized:
      //print("central.state is .unauthorized")
      break
    case .poweredOff:
      //print("central.state is .poweredOff")
      break
    case .poweredOn:
      //print("central.state is .poweredOn")
      centralManager.scanForPeripherals(withServices: [UartGattServiceId])
      break
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    //print(peripheral)
    heartRatePeripheral = peripheral
    heartRatePeripheral.delegate = self
    centralManager.stopScan()
    centralManager.connect(heartRatePeripheral)
  }
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    //print("fail to connect, error: \(error.debugDescription)")
    print("fail to connect, error: \(error.debugDescription)")
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    heartRatePeripheral = peripheral // has to store peripheral expicily otherwise it will be disposed and break the pending connection
    centralManager.connect(heartRatePeripheral)
    //print("Disconnect handler activated")
    print("disconnection detected")
    bluetoothConnection.text = "Bluetooth connection: disconnection"
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    //print("Connected!")
    print("connect")
      bluetoothConnection.text = "Bluetooth connection: connected"
    heartRatePeripheral.discoverServices([UartGattServiceId])
  }
}

@available(iOS 14.0, *)
extension HomeViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    for service in services {
      //print(service)
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else { return }
    
    for characteristic in characteristics {
      //print("newly discovered characteristic:")
      //print(characteristic)

      if characteristic.properties.contains(.read) {
        //print("\(characteristic.uuid): properties contains .read")
        peripheral.readValue(for: characteristic)
      }
      if characteristic.properties.contains(.notify) {
        //print("\(characteristic.uuid): properties contains .notify")
        //peripheral.setNotifyValue(true, for: characteristic)
      }
      if characteristic.properties.contains(.write) {
        //print("\(characteristic.uuid): properties contains .write")
        if characteristic.uuid.isEqual(UartGattCharacteristicSendId) {
          char_external_write = characteristic
          write(raw_value: dataToSend!, characteristic: characteristic)
        }
      }
      func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        // peripheral execute this method after a failed call to write value and after the peripheral is ready for the 2nd time write.
        //print("resend write request")
        write(raw_value: dataToSend!, characteristic: characteristic)
        
      }
    }
  }
  

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    switch characteristic.uuid {
    case UartGattCharacteristicSendId:
      //print("do nothing when sent charcteristic value updates")
      //centralManager.cancelPeripheralConnection(peripheral)
      //var a = centralManager.scanForPeripherals(withServices: [UartGattServiceId])
      
      if let error = error {
        //print("ERROR: write unsuccessful")
        //print(error.localizedDescription)
        print("ERROR: write unsuccessful")
        
        centralManager.scanForPeripherals(withServices: [UartGattServiceId])
        
        return
      }
//      let bodySensorLocation = Process_Characteristics(from: characteristic)
//      bodySensorLocationLabel.text = bodySensorLocation
    case UartGattCharacteristicReceiveId:
      //print(characteristic.value ?? "no value") // this will be a value where you need to write function to interpret
      print("data received")
      
      
      print(String(data: characteristic.value!, encoding: .utf8));
      break
    default:
      //print("Unhandled Characteristic UUID: \(characteristic.uuid)")
      break
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    if (error == nil) {
      print("received write with response successful")
    } else {
        print(error?.localizedDescription)
        print("write with response unsuccessful")
    }

  }
  func write(raw_value: Data, characteristic: CBCharacteristic) {
    
    var value = raw_value;
    value.append(0x0);//add null terminator
    if (heartRatePeripheral == nil || heartRatePeripheral.state != CBPeripheralState.connected) {
      centralManager.scanForPeripherals(withServices: [UartGattServiceId])
    }
    
    
    
    // Based on experimentation, it's about 239 char at a time.
    var max_bytes_per_packet_without_response = heartRatePeripheral.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse)
    
    // Based on experimentation, it's about 512 char(i.e. bytes) at a time.
    var max_bytes_per_packet_with_response = heartRatePeripheral.maximumWriteValueLength(for: CBCharacteristicWriteType.withResponse)
    
  
      if value.count < max_bytes_per_packet_with_response {
          heartRatePeripheral.writeValue(value, for: characteristic, type: .withResponse)
        
       print("\(self.get_state_name(state: self.heartRatePeripheral.state)), send time: \(self.get_time_stamp()), data content:\(String(data: value, encoding: .utf8)! as NSObject)")

        
      } else {
        //print("message size \(value.count) > maximum length of write with response \(max_bytes_per_packet_with_response)")
        print("message size \(value.count) > maximum length of write with response \(max_bytes_per_packet_with_response)")
      }
    //}
    
  }
  
  func get_time_stamp() -> String {
    var date = Date()
    let format = DateFormatter()
    // format.dateFormat = "yyyy-MM-dd HH:mm:ss"
    format.dateFormat = "yyyy-MM-dd HH:mm:ss:FFFF"
    var timeStamp = format.string(from: date)
    return timeStamp
  }
  
  func get_state_name(state: CBPeripheralState) -> String {
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
      
  }
}


