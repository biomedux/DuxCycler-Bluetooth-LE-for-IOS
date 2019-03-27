//
//  FileName: ByteUtil.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import Foundation

class ByteUtil {
    
    static func checksum(data: Data) -> UInt8 {
        var sum = 0
        
        for i in 0 ..< data.count {
            sum += Int(data[i])
        }
        
        return UInt8(~sum & 0xFF)
    }
    
    static func btoi(a: UInt8) -> Int {
        return Int(a)
    }
    
    static func btoi(a: UInt8, b: UInt8) -> Int {
        return Int((Int(a) << 8) + Int(b))
    }
    
    static func btod(a: UInt8, b: UInt8) -> Double {
        return Double(a) + Double(b) * 0.1
    }
}
