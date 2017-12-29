//
//  TradeManager.swift
//  LKWallet
//
//  Created by Hao Wang on 28/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation

enum TradeType: Int {
    case out = 0    // 出账
    case `in` = 1   // 入账
}

struct Trade {
    var type: TradeType
    var tradeAccount: String
    var amount: Double
    var cost: Double
    var timestamp: TimeInterval
    var hash: String
    var extra: String
    
    init(dict: [String: Any]) {
        self.type = TradeType(rawValue: dict["type"] as? Int ?? 0) ?? .out
        self.tradeAccount = dict["tradeAccount"] as? String ??  ""
        self.amount = Double(hexString: dict["amount"] as? String ?? "0")
        self.cost = Double(hexString: dict["cost"] as? String ?? "0")
        self.timestamp = TimeInterval(dict["timestamp"] as? String ?? "0") ?? Date.timeIntervalBetween1970AndReferenceDate
        self.hash = dict["hash"] as? String ?? ""
        self.extra = dict["extra"] as? String ?? ""
    }
}

class TradeManager {
    
    static let shared = TradeManager()
    private init() { }
}

