//
//  Double.swift
//  LKWallet
//
//  Created by Hao Wang on 17/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation

// MARK: - Double Extension

extension Double {
    init(hexString: String) {
        var str = hexString.uppercased()
        if str.hasPrefix("0X") {
            if let range = str.range(of: "0X") {
                str = String(str[range.upperBound...])
            }
        }
        var sum: Double = 0
        for i in str.utf8 {
            sum = sum * 16 + Double(i) - 48 // 0-9 从48开始
            if i >= 65 {                    // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        self = sum / 1000000000000000000.0
    }
}
