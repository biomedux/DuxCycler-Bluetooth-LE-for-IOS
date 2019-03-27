//
//  FileName: Action.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class Action: Equatable {
    
    var label = 0
    var temp = 0
    var time = 0
    var remain = 0
    
    init(label: Int, temp: Int, time: Int) {
        self.label = label
        self.temp = temp
        self.time = time
    }
    
    static func == (action1: Action, action2: Action) -> Bool {
        if action1.label != action2.label {
            return false
        }
        
        if action1.temp != action2.temp {
            return false
        }
        
        if action1.time != action2.time {
            return false
        }
        
        return true
    }
    
    func copy() -> Action {
        let action = Action(label: label, temp: temp, time: time)
        
        action.remain = self.remain
        
        return action
    }
    
    func isGoto() -> Bool {
        return label == TxProtocol.AF_GOTO
    }
}
