//
//  FileName: ActionUtil.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class ActionUtil {
    
    static func makeDefault() -> Protocol {
        let proto = Protocol()
        
        proto.title = "Default"
        proto.actions.append(Action(label: 1, temp: 95, time: 180))
        proto.actions.append(Action(label: 2, temp: 95, time: 10))
        proto.actions.append(Action(label: 3, temp: 60, time: 30))
        proto.actions.append(Action(label: 4, temp: 72, time: 30))
        proto.actions.append(Action(label: 250, temp: 2, time: 34))
        proto.actions.append(Action(label: 5, temp: 95, time: 10))
        proto.actions.append(Action(label: 6, temp: 50, time: 30))
        
        return proto
    }
    
    static func calcTime(selectedProtocol: Protocol) -> Int {
        let actions = selectedProtocol.actions
        var time = 0
        
        var sum: Int
        var offset: Int
        
        for i in 0 ..< actions.count {
            if actions[i].isGoto() {
                sum = 0
                offset = 0
                
                for j in 0 ..< actions.count {
                    if actions[i].temp == actions[j].label {
                        offset = j
                        break
                    }
                }
                
                for j in offset ..< i {
                    sum += actions[j].time
                }
                
                time += sum * actions[i].time
            } else {
                time += actions[i].time
            }
        }
        
        return time
    }
    
    static func toHMS(time: Int) -> String {
        let hour = time / 3600
        let minute = time / 60 % 60
        let second = time % 60
        
        var hms = ""
        
        if hour != 0 {
            hms += String(hour) + "h"
        }
        
        if minute != 0 {
            if hms != "" {
                hms += " "
            }
            
            hms += String(minute) + "m"
        }
        
        if second != 0 {
            if hms != "" {
                hms += " "
            }
            
            hms += String(second) + "s"
        }
        
        return hms == "" ? "0s" : hms
    }
}
