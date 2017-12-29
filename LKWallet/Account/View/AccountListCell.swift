//
//  AccountListCell.swift
//  LKWallet
//
//  Created by Hao Wang on 2017/11/18.
//  Copyright © 2017年 Tuluobo. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol AccountListCellDelegate: class {
    func accountListCell(_ cell: AccountListCell, show qrImage: UIImage)
}

class AccountListCell: UITableViewCell {
    
    weak var delegate: AccountListCellDelegate?
    var viewModel: AccountViewModel? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        cardView.layer.cornerRadius = 8
        cardView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        cardView.layer.borderWidth = 1
    }
    
    private func updateUI() {
        
        accountNameLabel.text = "账户"
        addressLabel.text = nil
        amountLabel.text = "0"
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        accountNameLabel.text = viewModel.account.name
        addressLabel.text = viewModel.account.address
        
        viewModel.amountAction.apply().startWithResult { (result) in
            switch result {
            case .failure(let error):
                SVProgressHUD.showError(withStatus: "账号：\(viewModel.account.address)获取余额错误。Error: \(error.localizedDescription)")
            case .success(let value):
                self.amountLabel.text = "\(value)"
            }
        }
    }
    
    @IBAction func clickShowQRImageBtn() {
        guard let image = viewModel?.qrImage else {
            SVProgressHUD.showError(withStatus: "二维码生成错误！")
            return
        }
        delegate?.accountListCell(self, show: image)
    }
    
}
