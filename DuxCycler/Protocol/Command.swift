//
//  FileName: Command.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

enum Command: UInt8 {
    
    case NOP = 0
    case TASK_WRITE
    case TASK_END
    case GO
    case STOP
    case BOOTLOADER
    
}
