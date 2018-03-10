//
//  AccountManager.swift
//  LKWallet
//
//  Created by Hao Wang on 27/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation

class AccountManager {
    
    static let manager = AccountManager()
    private init() { }
    
    var count: Int {
        guard let accounts = UserDefaults.standard.array(forKey: kAccountLocalSaveKey) as? [[String: Any]] else {
            return 0
        }
        return accounts.count
    }
    
    func verify(account: Account) -> Bool {
        let accountStr = account.address.lowercased()
        if !accountStr.hasPrefix("0x") { return false }
        if accountStr.count != 42 { return false }
        return true
    }
    
    func add(accounts: [Account]) -> Bool {
        var savedAccounts = queryAllAccount()
        for index in (0..<savedAccounts.count).reversed() {
            if accounts.contains(savedAccounts[index]) {
                savedAccounts.remove(at: index)
            }
        }
        savedAccounts.append(contentsOf: accounts)
        return save(accounts: savedAccounts)
    }
    
    func delete(accounts: [Account]) -> Bool {
        var savedAccounts = queryAllAccount()
        for index in (0..<savedAccounts.count).reversed() {
            let account = savedAccounts[index]
            if accounts.contains(account) {
                if account.hasWallet {
                    if case .failure = OneKeyStore().delete(account: account) {
                        return false
                    }
                }
                savedAccounts.remove(at: index)
            }
        }
        return save(accounts: savedAccounts)
    }
    
    func queryAllAccount() -> [Account] {
        guard let accountDicts = UserDefaults.standard.array(forKey: kAccountLocalSaveKey) as? [[String: Any]] else {
            return []
        }
        let accounts = accountDicts.map(Account.init)
        return accounts
    }
    
    func save(accounts: [Account]) -> Bool {
        let dicts = accounts.map { $0.dictionary() }
        UserDefaults.standard.set(dicts, forKey: kAccountLocalSaveKey)
        return UserDefaults.standard.synchronize()
    }
}
