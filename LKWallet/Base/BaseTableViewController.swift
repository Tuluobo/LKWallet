//
//  BaseTableViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 29/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit
import GoogleMobileAds
import ReactiveSwift

class BaseTableViewController: UITableViewController, AdBannerProtocol {

    var isHiddenAdBanner = MutableProperty<Bool>(false)
    lazy var adBanner: GADBannerView = createAdBanner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(adBanner)
        adBanner.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        self.isHiddenAdBanner.producer.startWithValues { [weak self] (hidden) in
            guard let `self` = self else { return }
            self.adBanner.isHidden = hidden
            var inset = self.tableView.contentInset
            inset.bottom = hidden ? self.bottomLayoutGuide.length : self.adBanner.bounds.size.height
            self.tableView.contentInset = inset
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isHiddenAdBanner.value = UserDefaults.standard.bool(forKey: kRemoveAdProductKey)
    }
}
