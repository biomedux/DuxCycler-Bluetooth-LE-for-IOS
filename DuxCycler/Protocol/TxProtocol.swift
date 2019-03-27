//
//  FileName: TxProtocol.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

enum TxProtocol: Int {
    
    case COMMAND = 0
    case LABEL
    case TEMP
    case TIME_H
    case TIME_L
    case LID_TEMP
    case REQ_LINE
    case INDEX
    case CHECKSUM
    
    static let BUFFER_SIZE = 20
    static let AF_GOTO = 250
    
}
