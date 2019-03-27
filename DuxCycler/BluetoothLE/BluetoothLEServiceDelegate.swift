//
//  FileName: BluetoothLEServiceDelegate.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

protocol BluetoothLEServiceDelegate {
    
    func bluetoothLEScan(device: BluetoothLEDevice)
    
    func bluetoothLEUpdateState(state: Int)
    
    func bluetoothLEEvent(msg: Int)
    
    func bluetoothLEReceived(rxData: RxData)
}
