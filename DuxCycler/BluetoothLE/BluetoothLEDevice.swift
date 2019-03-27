//
//  FileName: BluetoothLEDevice.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

import CoreBluetooth

class BluetoothLEDevice {
    
    var peripheral: CBPeripheral?
    
    var name: String
    var uuid: String
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        name = peripheral.name!
        uuid = peripheral.identifier.uuidString
    }
    
    init(name: String, uuid: String) {
        self.name = name
        self.uuid = uuid
    }
}
