//
//  QRShowViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 19/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit
import PopupController
import SnapKit

class QRShowViewController: UIViewController, PopupContentViewController {
    
    private var image: UIImage
    
    @objc init(image: UIImage) {
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: image.size))
        imageView.image = image
        self.view.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        let imageSize = image.size
        var popSize = CGSize(width: imageSize.width + 8, height: imageSize.height + 8)
        if screenSize.width < popSize.width {
            popSize.width = screenSize.width
        }
        if screenSize.height < popSize.height {
            popSize.height = screenSize.height
        }
        return popSize
    }
}
