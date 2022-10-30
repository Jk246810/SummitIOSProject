//
//  File.swift
//  SummitUIAppNew
//
//  Created by Jamee Krzanich on 10/30/22.
//

import Foundation
import CoreBluetooth

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

}


