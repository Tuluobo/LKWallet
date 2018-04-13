//
//  RequestTool.swift
//  LKWallet
//
//  Created by Hao Wang on 2018/4/7.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import CryptoSwift

class RequestTool {
    
    static func sign(jsonString: String) throws -> [String: Any] {
        guard let base64Json = jsonString.data(using: String.Encoding.utf8)?.base64EncodedString() else {
            throw NetError.data("数据格式错误！")
        }
        let timestamp = Int64(Date().timeIntervalSince1970)
        let sign = self.cryptoData(with: base64Json + "\(timestamp)")
        return ["data": base64Json,
                "timestamp": timestamp,
                "sign": sign]
        
    }
    
    static func cryptoData(with string: String) -> String {
        return string.md5()
            .exchangeCharater(index1: 2, index2: 8)
            .exchangeCharater(index1: 17, index2: 27)
            .md5()
    }
}
