//
//  FileName: Protocol.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class Protocol: Equatable {
    
    var title = ""
    var actions = [Action]()
    
    static func == (protocol1: Protocol, protocol2: Protocol) -> Bool {
        if protocol1.title != protocol2.title {
            return false
        }
        
        if protocol1.actions.count != protocol2.actions.count {
            return false
        }
        
        for i in 0 ..< protocol1.actions.count {
            if protocol1.actions[i] != protocol2.actions[i] {
                return false
            }
        }
        
        return true
    }
    
    func copy() -> Protocol {
        let proto = Protocol()
        
        proto.title = self.title
        
        for i in 0..<self.actions.count {
            proto.actions.append(self.actions[i].copy())
        }
        
        return proto
    }
    
    func indexOf(label: Int) -> Int {
        for i in 0 ..< actions.count {
            if actions[i].label == label {
                return i
            }
        }
        
        return -1
    }
    
    func getLastLabel(endIndex: Int) -> Int {
        for i in (0 ..< endIndex).reversed() {
            if !actions[i].isGoto() {
                return actions[i].label
            }
        }
        
        return 0
    }
    
    func clearRemain() {
        for i in 0 ..< actions.count {
            actions[i].remain = 0
        }
    }
}
