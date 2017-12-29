//
//  CommonManager.swift
//  LKWallet
//
//  Created by Hao Wang on 2017/11/24.
//  Copyright © 2017年 Tuluobo. All rights reserved.
//

import Foundation

class CommonManager {
    static let shared = CommonManager()
    private init() { }
    
    func setupFix() {
        fixV022ToV023Data()
    }
    
    private func fixV022ToV023Data() {
        let fixKey = "V022ToV023FixKey"
        guard !(UserDefaults.standard.bool(forKey: fixKey)) else {
            return
        }
        // 开始修复
        guard let dicts = UserDefaults.standard.array(forKey: kAccountLocalSaveKey) as? [[String: Any]] else {
            return
        }
        let newDicts = dicts.flatMap { (dict) -> [String: Any]? in
            var newDict = dict
            if let name = dict["name"] as? String, name.count > 0 {
                newDict["name"] = name
            } else {
                newDict["name"] = "默认账户"
            }
            if let address = dict["account"] as? String {
                newDict["address"] = address
            }
            newDict["hasWallet"] = dict["hasWallet"] as? Bool ?? false
            guard let address = newDict["address"] as? String, address.count == 42 else {
                return nil
            }
            return newDict
        }
        UserDefaults.standard.set(newDicts, forKey: kAccountLocalSaveKey)
        UserDefaults.standard.set(true, forKey: fixKey)
        UserDefaults.standard.synchronize()
    }
}
