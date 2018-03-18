//
//  ImportAccountViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 18/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import Result
import SnapKit

class ImportAccountViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private lazy var firstStepLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "第一步：将备份钱包文件通过QQ/微信发到iPhone上"
        return label
    }()
    private lazy var secondStepLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "第二步：点击用其他应用打开，选择玩客钱包"
        return label
    }()
    private lazy var thirdStepLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "第三步：打开玩客钱包时，选择导入"
        return label
    }()
    private lazy var firstStepImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "export-1"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var secondStepImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "export-2"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var thirdStepImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "export-3"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "钱包导入"
        self.isHiddenAdBanner.producer.startWithValues { [weak self] (hidden) in
            guard let `self` = self else { return }
            self.adBanner.isHidden = hidden
            var inset = self.scrollView.contentInset
            inset.bottom = hidden ? self.bottomLayoutGuide.length : self.adBanner.bounds.size.height
            self.scrollView.contentInset = inset
        }
        
        scrollView.addSubview(firstStepLabel)
        scrollView.addSubview(secondStepLabel)
        scrollView.addSubview(thirdStepLabel)
        scrollView.addSubview(firstStepImageView)
        scrollView.addSubview(secondStepImageView)
        scrollView.addSubview(thirdStepImageView)
        
        let defaultWidth = self.view.width - 30 * 2
        firstStepLabel.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.width.equalTo(defaultWidth)
            make.centerX.equalToSuperview()
        }
        
        firstStepImageView.snp.makeConstraints { (make) in
            make.top.equalTo(firstStepLabel.snp.bottom).offset(20)
            make.width.equalTo(defaultWidth)
            make.height.equalTo(220)
            make.centerX.equalToSuperview()
        }
        
        secondStepLabel.snp.makeConstraints { (make) in
            make.top.equalTo(firstStepImageView.snp.bottom).offset(20)
            make.width.equalTo(defaultWidth)
            make.centerX.equalToSuperview()
        }
        
        secondStepImageView.snp.makeConstraints { (make) in
            make.top.equalTo(secondStepLabel.snp.bottom).offset(20)
            make.width.equalTo(defaultWidth)
            make.height.equalTo(220)
            make.centerX.equalToSuperview()
        }
        
        thirdStepLabel.snp.makeConstraints { (make) in
            make.top.equalTo(secondStepImageView.snp.bottom).offset(20)
            make.width.equalTo(defaultWidth)
            make.centerX.equalToSuperview()
        }
        
        thirdStepImageView.snp.makeConstraints { (make) in
            make.top.equalTo(thirdStepLabel.snp.bottom).offset(20)
            make.width.equalTo(defaultWidth)
            make.height.equalTo(220)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
    }
}

