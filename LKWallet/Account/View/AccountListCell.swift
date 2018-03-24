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
    func accountListCell(_ cell: AccountListCell, clickedTransactionWith account: Account)
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
    @IBOutlet weak var transactionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        cardView.layer.cornerRadius = 8.0
        cardView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        cardView.layer.borderWidth = 1.0
        
        transactionBtn.addTarget(self, action: #selector(clickedTransaction), for: .touchUpInside)
        transactionBtn.layer.borderColor = UIColor(red: 69.0 / 255.0, green: 122.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0).cgColor
        transactionBtn.layer.borderWidth = 1.0
        transactionBtn.layer.cornerRadius = transactionBtn.height * 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accountNameLabel.text = "账户"
        addressLabel.text = nil
        amountLabel.text = "0"
        transactionBtn.isHidden = true
    }
    
    private func updateUI() {
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        accountNameLabel.text = viewModel.account.name
        addressLabel.text = viewModel.account.address
        transactionBtn.isHidden = !viewModel.account.hasWallet
        
        viewModel.amountAction.apply().startWithResult { (result) in
            switch result {
            case .failure(let error):
                SVProgressHUD.showError(withStatus: "账号：\(viewModel.account.address)获取余额错误。Error: \(error.localizedDescription)")
            case .success(let value):
                self.amountLabel.text = "\(value)"
            }
        }
    }

    static func preferredDimension(for viewModel: AccountViewModel, in container: UITableView) -> CGFloat {
        if viewModel.account.hasWallet {
            return 180.0
        } else {
            return 142.0
        }
    }
    
    @IBAction func clickShowQRImageBtn() {
        guard let image = viewModel?.qrImage else {
            SVProgressHUD.showError(withStatus: "二维码生成错误！")
            return
        }
        delegate?.accountListCell(self, show: image)
    }
    
    @objc private func clickedTransaction() {
        guard let viewModel = viewModel, viewModel.account.hasWallet else {
            SVProgressHUD.showError(withStatus: "没有钱包文件或账户信息错误！")
            return
        }
        viewModel.amountAction.apply().startWithResult { [weak self] (result) in
            guard let `self` = self else {
                SVProgressHUD.showError(withStatus: "发起转账异常！")
                return
            }
            switch result {
            case .failure(let error):
                SVProgressHUD.showError(withStatus: "账号：\(viewModel.account.address)获取余额错误。Error: \(error.localizedDescription)")
            case .success(let value):
                if value <= 0.01 {
                    SVProgressHUD.showError(withStatus: "账户余额不足，不能转账！")
                } else {
                    self.delegate?.accountListCell(self, clickedTransactionWith: viewModel.account)
                }
            }
        }
    }
    
}
