//
//  CreateResultViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 18/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import Result
import SVProgressHUD

class CreateResultViewController: BaseViewController {
    
    var createResult: Result<Account, KeyStoreError>?
    
    private var account: Account?
    
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var tipsTitleLabel: UILabel!
    @IBOutlet weak var tipsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        handleResult()
    }
    
    private func handleResult() {
        guard let result = createResult else {
            SVProgressHUD.showError(withStatus: "发生未知错误！")
            return
        }
        
        switch result {
        case .success(let account):
            self.account = account
            if AccountManager.manager.add(accounts: [account]) {
                self.navigationItem.title = "钱包创建成功"
                success(account: account)
            } else {
                self.navigationItem.title = "钱包保存失败"
                failure(error: .failedToCreateWallet)
            }
        case .failure(let error):
            self.navigationItem.title = "钱包创建失败"
            failure(error: error)
        }
    }
    
    private func success(account: Account) {
        self.resultImageView.image = #imageLiteral(resourceName: "ic_success")
        self.resultLabel.text = "账户创建成功"
        self.addressTitleLabel.text = "您的账户地址："
        self.addressLabel.text = account.address
        self.qrCodeImageView.image = UIImage.createQRImage(string: account.address)
    }
    
    private func failure(error: KeyStoreError) {
        self.resultImageView.image = #imageLiteral(resourceName: "ic_error")
        self.resultLabel.text = "账户创建失败"
        self.addressTitleLabel.text = "错误原因："
        self.addressLabel.text = "\(error.localizedDescription)"
        
        self.qrCodeImageView.isHidden = true
        self.tipsTitleLabel.isHidden = true
        self.tipsTextView.isHidden = true
    }
    
    @IBAction func clickedCompletionBtn(_ sender: UIBarButtonItem) {
        guard let account = self.account else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        let alertVc = UIAlertController(title: "钱包备份", message: "是否需要备份钱包？", preferredStyle: UIAlertControllerStyle.alert)
        alertVc.addAction(UIAlertAction(title: "立即备份", style: UIAlertActionStyle.destructive, handler: { [weak self] (_) in
            self?.exportWallet(account: account)
        }))
        alertVc.addAction(UIAlertAction(title: "不备份", style: UIAlertActionStyle.cancel, handler: { (_) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alertVc, animated: true, completion: nil)
    }
    
    private func exportWallet(account: Account) {
        switch OneKeyStore().export(account: account) {
        case .success(let path):
            let fileURL = URL(fileURLWithPath: path)
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.permittedArrowDirections = .any
            }
            self.present(activityVC, animated: true, completion: {
                self.navigationController?.popToRootViewController(animated: true)
            })
        case .failure(let error):
            SVProgressHUD.showError(withStatus: "账户异常，请重新尝试！Error: \(error.localizedDescription)")
        }
    }
    
}

