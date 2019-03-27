//
//  FileName: BluetoothLEUUID.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class BluetoothLEUUID {
    
    // UUID for the UART BTLE client characteristic which is necessary for notifications.
    static let CLIENT = "00002902-0000-1000-8000-00805f9b34fb"
    
    // UUIDs for UART service and associated characteristics.
    static let UART = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    static let TX = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    static let RX = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    
    // UUIDs for the Device Information service and associated characeristics.
    static let DIS = "0000180a-0000-1000-8000-00805f9b34fb"
    static let DIS_MANUF = "00002a29-0000-1000-8000-00805f9b34fb"
    static let DIS_MODEL = "00002a24-0000-1000-8000-00805f9b34fb"
    static let DIS_HWREV = "00002a26-0000-1000-8000-00805f9b34fb"
    static let DIS_SWREV = "00002a28-0000-1000-8000-00805f9b34fb"
    
}
