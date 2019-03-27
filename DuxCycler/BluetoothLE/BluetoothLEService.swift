//
//  FileName: BluetoothLEService.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

import CoreBluetooth

class BluetoothLEService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var central: CBCentralManager!
    var peripheral: CBPeripheral?
    
    var writeCharacteristic: CBCharacteristic?
    
    var delegate: BluetoothLEServiceDelegate?
    var connectTimer: Timer?
    
    var rawData = Data()
    
    override init() {
        super.init()
        
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.bluetoothLEUpdateState(state: central.state.rawValue)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            if name == "DuxCycler" {
                delegate?.bluetoothLEScan(device: BluetoothLEDevice(peripheral: peripheral))
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectTimer?.invalidate()
        connectTimer = nil
        
        delegate?.bluetoothLEEvent(msg: 0)
        
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.bluetoothLEEvent(msg: 1)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid.uuidString == BluetoothLEUUID.UART {
                    peripheral.discoverCharacteristics(nil, for: service)
                    break
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid.uuidString == BluetoothLEUUID.TX {
                    writeCharacteristic = characteristic
                }
                
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        delegate?.bluetoothLEEvent(msg: 2)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            rawData.append(data)
            
            if rawData.count == 20 {
                let rxData = RxData(data: rawData)
                
                if rxData.validPacket {
                    delegate?.bluetoothLEReceived(rxData: rxData)
                }
                
                rawData.removeAll()
            }
        }
    }
    
    func connect(device: BluetoothLEDevice) {
        rawData.removeAll()
        
        peripheral = device.peripheral
        peripheral!.delegate = self
        
        central.connect(peripheral!)
        
        connectTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
    }
    
    @objc func timeout() {
        central.cancelPeripheralConnection(peripheral!)
    }
    
    func scanStart() {
        central.scanForPeripherals(withServices: nil)
    }
    
    func scanStop() {
        central.stopScan()
    }
    
    func close() {
        central.cancelPeripheralConnection(peripheral!)
    }
    
    func write(data: Data) {
        peripheral?.writeValue(data, for: writeCharacteristic!, type: .withResponse)
    }
    
    func isConnected() -> Bool {
        return peripheral?.state == CBPeripheralState.connected
    }
}
