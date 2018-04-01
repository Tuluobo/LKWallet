//
//  TransactionResultViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 2018/3/31.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TransactionResultViewController: BaseViewController {

    var transferAccount: Account?
    var receiveAccount: Account?
    var password: String?
    var amount: Double = 0
    
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "转账结果"
        self.navigationItem.hidesBackButton = true

        returnButton.setBackgroundImage(normalColorImage, for: .normal)
        returnButton.setBackgroundImage(disabledColorImage, for: .disabled)
        returnButton.layer.borderWidth = 1.0
        returnButton.layer.borderColor = bordColor.cgColor
        returnButton.layer.cornerRadius = returnButton.height * 0.5
        returnButton.layer.masksToBounds = true
        returnButton.addTarget(self, action: #selector(clickedReturnBtn(button:)), for: .touchUpInside)
        
        resultImageView.isHidden = true
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        loadingView.type = .ballSpinFadeLoader
        loadingView.color = normalColor
        
        returnButton.isHidden = true
        
        handleTransaction()
    }

    private func handleTransaction() {
        guard let transferAccount = transferAccount,
            let receiveAccount = receiveAccount,
            let password = password,
            amount > 0 else {
            return
        }
        loadingView.startAnimating()
        loadingLabel.text = "正在处理中 ... ..."
        
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            let result = EthereumManager.shared.sendTransaction(sourceAccount: transferAccount, passphrase: password, receiveAccount: receiveAccount, dealAmount: self.amount)
            DispatchQueue.main.async { [weak self] in
                self?.loadingView.stopAnimating()
                self?.resultImageView.isHidden = false
                self?.returnButton.isHidden = false
                
                switch result {
                case .success(let receipt):
                    self?.resultImageView.image = #imageLiteral(resourceName: "ic_success")
                    self?.loadingLabel.text = "转账处理完成，3-5分钟后会在交易加载完成。\nTransaction Receipt: \(receipt.string())"
                    self?.returnButton.setTitle("完成", for: .normal)
                case .failure(let error):
                    let errorDesc: String
                    if case .otherError(let err) = error, let keyStoreError = err as? KeyStoreError {
                        errorDesc = keyStoreError.errorDescription
                    } else {
                        errorDesc = error.errorDescription
                    }
                    
                    self?.resultImageView.image = #imageLiteral(resourceName: "ic_error")
                    self?.loadingLabel.text = "\(errorDesc)"
                    self?.returnButton.setTitle("再次重试", for: .normal)
                }
            }
        }
    }
    
    @objc private func clickedReturnBtn(button: UIButton) {
        guard let title = button.currentTitle else {
            return
        }
        if title == "再次重试" {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}
