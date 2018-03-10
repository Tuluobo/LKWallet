//
//  AccountModel.swift
//  LKWallet
//
//  Created by Hao Wang on 19/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import Geth

struct Account {
    var name: String
    var address: String
    var hasWallet: Bool
    
    init(name: String?, address: String, hasWallet: Bool = false) {
        if let _name = name, _name.count > 0 {
            self.name = _name
        } else {
            self.name = "账户\(AccountManager.manager.count + 1)"
        }
        self.address = address
        self.hasWallet = hasWallet
    }
    
    init(account: GethAccount) {
        self.name = "钱包账户"
        self.address = account.getAddress().getHex().lowercased()
        self.hasWallet = true
    }
    
    init(dict: [String: Any]) {
        if let name = dict["name"] as? String, name.count > 0 {
            self.name = name
        } else {
            self.name = "账户\(AccountManager.manager.count + 1)"
        }
        self.address = dict["address"] as? String ?? ""
        self.hasWallet = dict["hasWallet"] as? Bool ?? false
    }
}

extension Account {
    func dictionary() -> [String: Any] {
        return ["name": self.name, "address": self.address, "hasWallet": self.hasWallet]
    }
}

extension Account: Equatable {
    static func ==(lhs: Account, rhs: Account) -> Bool {
        return lhs.address == rhs.address
    }
}
