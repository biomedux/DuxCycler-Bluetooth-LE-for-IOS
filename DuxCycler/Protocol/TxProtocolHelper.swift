//
//  FileName: TxProtocolHelper.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class TxProtocolHelper {
    
    static func makeNop() -> Data {
        var data = Data(count: TxProtocol.BUFFER_SIZE)
        
        data[TxProtocol.COMMAND.rawValue] = Command.NOP.rawValue
        data[TxProtocol.CHECKSUM.rawValue] = ByteUtil.checksum(data: data)
        
        return data
    }
    
    static func makeTaskWrite(action: Action, preheat: Int, line: Int) -> Data {
        var data = Data(count: TxProtocol.BUFFER_SIZE)
        
        data[TxProtocol.COMMAND.rawValue] = Command.TASK_WRITE.rawValue
        
        data[TxProtocol.LABEL.rawValue] = UInt8(action.label)
        data[TxProtocol.TEMP.rawValue] = UInt8(action.temp)
        data[TxProtocol.TIME_H.rawValue] = UInt8(action.time >> 8)
        data[TxProtocol.TIME_L.rawValue] = UInt8(action.time)
        data[TxProtocol.LID_TEMP.rawValue] = UInt8(preheat)
        data[TxProtocol.REQ_LINE.rawValue] = UInt8(line)
        data[TxProtocol.INDEX.rawValue] = UInt8(line)
        
        data[TxProtocol.CHECKSUM.rawValue] = ByteUtil.checksum(data: data)
        
        return data
    }
    
    static func makeTaskEnd() -> Data {
        var data = Data(count: TxProtocol.BUFFER_SIZE)
        
        data[TxProtocol.COMMAND.rawValue] = Command.TASK_END.rawValue
        data[TxProtocol.CHECKSUM.rawValue] = ByteUtil.checksum(data: data)
        
        return data
    }
    
    static func makeGo() -> Data {
        var data = Data(count: TxProtocol.BUFFER_SIZE)
        
        data[TxProtocol.COMMAND.rawValue] = Command.GO.rawValue
        data[TxProtocol.CHECKSUM.rawValue] = ByteUtil.checksum(data: data)
        
        return data
    }
    
    static func makeStop() -> Data {
        var data = Data(count: TxProtocol.BUFFER_SIZE)
        
        data[TxProtocol.COMMAND.rawValue] = Command.STOP.rawValue
        data[TxProtocol.CHECKSUM.rawValue] = ByteUtil.checksum(data: data)
        
        return data
    }
    
    static func makeBootloader() -> Data {
        var data = Data(count: TxProtocol.BUFFER_SIZE)
        
        data[TxProtocol.COMMAND.rawValue] = Command.BOOTLOADER.rawValue
        data[TxProtocol.CHECKSUM.rawValue] = ByteUtil.checksum(data: data)
        
        return data
    }
    
    static func makeRequestLine(line: Int) -> Data {
        var data = Data(count: TxProtocol.BUFFER_SIZE)
        
        data[TxProtocol.COMMAND.rawValue] = Command.NOP.rawValue
        data[TxProtocol.REQ_LINE.rawValue] = UInt8(line)
        data[TxProtocol.CHECKSUM.rawValue] = ByteUtil.checksum(data: data)
        
        return data
    }
}
