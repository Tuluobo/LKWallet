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

let normalColor = UIColor(hex: "#418BF7")!
let disabledColor = UIColor(hex: "#418BF7")!.withAlphaComponent(0.5)
let bordColor = UIColor(red: 21.0 / 255.0, green: 72.0 / 255.0, blue: 110.0 / 255.0, alpha: 0.4)

let normalColorImage = UIImage.image(with: normalColor)
let disabledColorImage = UIImage.image(with: disabledColor)

// MARK: - Constant
let kAccountLocalSaveKey = "kAccountLocalSaveKey"
let kRemoveAdProductKey = "WKWallet.RemoveAD"
let kOpenKeyStoreFileNotification = "kOpenKeyStoreFileNotification"
let kAccountChangeNotification = "kAccountChangeNotification"

let kAddAccountSegueKey = "kAddAccountSegueKey"
let kQRCodeAddSegueKey = "kQRCodeAddSegueKey"
let kCreateAccountSegueKey = "kCreateAccountSegueKey"
let kImportAccountSegueKey = "kImportAccountSegueKey"
let kCreateAccountResultSegueKey = "kCreateAccountResultSegueKey"
let kEditAccountSegueKey = "kEditAccountSegueKey"
let kResetPasswdSegueKey = "kResetPasswdSegueKey"
let kTransactionDetailSegueKey = "kTransactionDetailSegueKey"
let kConfirmPasswordSegueKey = "kConfirmPasswordSegueKey"
let kTransactionResultSegueKey = "kTransactionResultSegueKey"

// MARK: - Third SDK Key
private let keyOfAdMob = "ca-app-pub-9047041794532200~2074026126"

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
        
        globalAppearanceConfig()
    }
    
    private func globalAppearanceConfig() {
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 69.0 / 255.0, green: 122.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
        ]
    }
}
