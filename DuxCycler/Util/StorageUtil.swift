//
//  FileName: StorageUtil.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class StorageUtil {
    
    static func saveProtocols(protocols: [Protocol], selectedIndex: Int) {
        UserDefaults.standard.set(selectedIndex, forKey: "selected_index")
        UserDefaults.standard.set(protocols.count, forKey: "protocol_count")
        
        for i in 0 ..< protocols.count {
            UserDefaults.standard.set(protocols[i].title, forKey: "protocol_title_" + String(i))
            UserDefaults.standard.set(protocols[i].actions.count, forKey: "action_count_" + String(i))
            
            for j in 0 ..< protocols[i].actions.count {
                UserDefaults.standard.set(protocols[i].actions[j].label, forKey: "action_label_" + String(i) + "_" + String(j))
                UserDefaults.standard.set(protocols[i].actions[j].temp, forKey: "action_temp_" + String(i) + "_" + String(j))
                UserDefaults.standard.set(protocols[i].actions[j].time, forKey: "action_time_" + String(i) + "_" + String(j))
            }
        }
    }
    
    static func loadProtocols() -> ([Protocol], Int) {
        let selectedIndex = UserDefaults.standard.integer(forKey: "selected_index")
        
        let protocolCount = UserDefaults.standard.integer(forKey: "protocol_count")
        var protocols = [Protocol]()
        
        var proto:Protocol
        
        var actionCount:Int
        
        for i in 0 ..< protocolCount {
            proto = Protocol()
            proto.title = UserDefaults.standard.string(forKey: "protocol_title_" + String(i))!
            actionCount = UserDefaults.standard.integer(forKey: "action_count_" + String(i))
            
            for j in 0 ..< actionCount {
                proto.actions.append(Action(
                    label: UserDefaults.standard.integer(forKey: "action_label_" + String(i) + "_" + String(j)),
                    temp: UserDefaults.standard.integer(forKey: "action_temp_" + String(i) + "_" + String(j)),
                    time: UserDefaults.standard.integer(forKey: "action_time_" + String(i) + "_" + String(j))
                ))
            }
            
            protocols.append(proto)
        }
        
        return (protocols, selectedIndex)
    }
    
    static func saveDevices(devices: [BluetoothLEDevice]) {
        UserDefaults.standard.set(devices.count, forKey: "device_count")
        
        for i in 0 ..< devices.count {
            UserDefaults.standard.set(devices[i].name, forKey: "device_name_" + String(i))
            UserDefaults.standard.set(devices[i].uuid, forKey: "device_uuid_" + String(i))
        }
    }
    
    static func loadDevices() -> [BluetoothLEDevice] {
        let deviceCount = UserDefaults.standard.integer(forKey: "device_count")
        var devices = [BluetoothLEDevice]()
        
        for i in 0 ..< deviceCount {
            devices.append(BluetoothLEDevice(
                name: UserDefaults.standard.string(forKey: "device_name_" + String(i))!,
                uuid: UserDefaults.standard.string(forKey: "device_uuid_" + String(i))!
            ))
        }
        
        return devices
    }
}
