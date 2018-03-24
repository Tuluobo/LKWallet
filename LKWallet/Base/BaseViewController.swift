//
//  BaseViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 2017/10/31.
//  Copyright © 2017年 Tuluobo. All rights reserved.
//

import UIKit
import GoogleMobileAds
import ReactiveSwift

protocol AdBannerProtocol {
    var isHiddenAdBanner: MutableProperty<Bool> { get }
    var adBanner: GADBannerView { get }
}

class BaseViewController: UIViewController, AdBannerProtocol {
    
    var isHiddenAdBanner = MutableProperty<Bool>(false)
    lazy var adBanner: GADBannerView = createAdBanner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(adBanner)
        adBanner.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isHiddenAdBanner.value = UserDefaults.standard.bool(forKey: kRemoveAdProductKey)
    }
}

extension UIViewController {
    func createAdBanner() -> GADBannerView {
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.rootViewController = self
        banner.adUnitID = "ca-app-pub-9047041794532200/9070679313"
        let request = GADRequest()
        #if DEBUG
            request.testDevices = [kGADSimulatorID, "4d9d2ff6b9a670553a33352bad3c5049", "d26dd26c011e852b92df1315c3fd4ff1"]
        #endif
        banner.load(request)
        return banner
    }
}
