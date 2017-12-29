//
//  ConfigManager.swift
//  LKWallet
//
//  Created by Hao Wang on 18/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import GoogleMobileAds
import Fabric
import Crashlytics

// MARK: - Constant
let kRemoveAdProductKey = "LKWallet.RemoveAD"
let kAccountLocalSaveKey = "kAccountLocalSaveKey"

// MARK: - Third SDK Key
let keyOfAdMob = "ca-app-pub-9047041794532200~2074026126"

// MARK: - ConfigManager
class ConfigManager {
    static let shared = ConfigManager()
    private init() { }
    
    func setup() {
        #if DEBUG
        #else
            // Fabric 崩溃收集
            Fabric.with([Crashlytics.self])
        #endif
        // Amplitude 统计
        TraceManager.shared.setup()
        // google 广告
        GADMobileAds.configure(withApplicationID: keyOfAdMob)
    }
}
