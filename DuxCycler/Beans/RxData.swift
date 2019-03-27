//
//  FileName: RxData.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class RxData {
    
    var state = 0
    var currentLabel = 0
    var gotoCount = 0
    var labelCount = 0
    var lineTime = 0
    var totalTime = 0
    var lidTemp = 0.0
    var chamberTemp = 0.0
    var heatTemp = 0
    var currentOperation = 0
    var error = 0
    var requestLine = 0
    var requestLabel = 0
    var requestTemp = 0
    var requestTime = 0
    var validPacket = false
    
    init(data: Data) {
        state = ByteUtil.btoi(a: data[RxProtocol.STATE.rawValue])
        currentLabel = ByteUtil.btoi(a: data[RxProtocol.CURRENT_LABEL.rawValue])
        gotoCount = ByteUtil.btoi(a: data[RxProtocol.GOTO_COUNT.rawValue])
        labelCount = ByteUtil.btoi(a: data[RxProtocol.LABEL_COUNT.rawValue])
        lineTime = ByteUtil.btoi(a: data[RxProtocol.LINE_TIME_H.rawValue], b: data[RxProtocol.LINE_TIME_L.rawValue])
        totalTime = ByteUtil.btoi(a: data[RxProtocol.TOTAL_TIME_H.rawValue], b: data[RxProtocol.TOTAL_TIME_L.rawValue])
        lidTemp = ByteUtil.btod(a: data[RxProtocol.LID_TEMP_H.rawValue], b: data[RxProtocol.LID_TEMP_L.rawValue])
        chamberTemp = ByteUtil.btod(a: data[RxProtocol.CHAMBER_TEMP_H.rawValue], b: data[RxProtocol.CHAMBER_TEMP_L.rawValue])
        heatTemp = ByteUtil.btoi(a: data[RxProtocol.HEAT_TEMP.rawValue])
        currentOperation = ByteUtil.btoi(a: data[RxProtocol.CURRENT_OPERATION.rawValue])
        error = ByteUtil.btoi(a: data[RxProtocol.ERROR_REQLINE.rawValue])
        requestLine = ByteUtil.btoi(a: data[RxProtocol.ERROR_REQLINE.rawValue])
        requestLabel = ByteUtil.btoi(a: data[RxProtocol.REQ_LABEL.rawValue])
        requestTemp = ByteUtil.btoi(a: data[RxProtocol.REQ_TEMP.rawValue])
        requestTime = ByteUtil.btoi(a: data[RxProtocol.REQ_TIME_H.rawValue], b: data[RxProtocol.REQ_TIME_L.rawValue])
        validPacket = ByteUtil.checksum(data: data) == 0
    }
    
    func getRequestAction() -> Action {
        return Action(label: requestLabel, temp: requestTemp, time: requestTime)
    }
}
