//
//  FileName: ProtocolManager.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class ProtocolManager {
    
    static let instance = ProtocolManager()
    
    var protocols = [Protocol]()
    var selectedIndex = -1
    
    private init() {
        
    }
    
    func load() {
        let result = StorageUtil.loadProtocols()
        
        protocols = result.0
        selectedIndex = result.1
        
        if (protocols.count == 0) {
            protocols.append(ActionUtil.makeDefault())
            selectedIndex = 0
        }
    }
    
    func save() {
        StorageUtil.saveProtocols(protocols: protocols, selectedIndex: selectedIndex)
    }
    
    func getSelectedProtocol() -> Protocol? {
        if selectedIndex == -1 {
            return nil
        }
        
        return protocols[selectedIndex]
    }
}
