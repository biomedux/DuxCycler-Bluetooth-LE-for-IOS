//
//  FileName: RxProtocol.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

enum RxProtocol: Int {
    
    case STATE = 0
    case CURRENT_LABEL
    case GOTO_COUNT
    case LABEL_COUNT
    case LINE_TIME_H
    case LINE_TIME_L
    case TOTAL_TIME_H
    case TOTAL_TIME_L
    case LID_TEMP_H
    case LID_TEMP_L
    case CHAMBER_TEMP_H
    case CHAMBER_TEMP_L
    case HEAT_TEMP
    case CURRENT_OPERATION
    case ERROR_REQLINE
    case REQ_LABEL
    case REQ_TEMP
    case REQ_TIME_H
    case REQ_TIME_L
    case CHEAKSUM
    
}
