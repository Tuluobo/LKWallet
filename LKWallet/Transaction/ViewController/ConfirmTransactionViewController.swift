//
//  ConfirmTransactionViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 2018/3/31.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import SVProgressHUD

private let cost: Double = 0.01

protocol ConfirmTransactionViewControllerDelegate: class {
    func confirmTransaction(viewController: ConfirmTransactionViewController, password: String)
}

class ConfirmTransactionViewController: BaseViewController {

    weak var delegate: ConfirmTransactionViewControllerDelegate?
    
    var transferAccount: Account?
    var receiveAccount: Account?
    var amount: Double = 0
    
    @IBOutlet weak var transferAddressLabel: UILabel!
    @IBOutlet weak var receiveAddressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var inputPwdView: UIView!
    @IBOutlet weak var inputViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPwdButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isHiddenAdBanner.value = true
        
        setupUI()

        guard let transferAccount = transferAccount, let receiveAccount = receiveAccount else {
            SVProgressHUD.showError(withStatus: "数据错误，请重试！")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        transferAddressLabel.text = transferAccount.address
        receiveAddressLabel.text = receiveAccount.address
        
        let amountLabelAttribute = NSMutableAttributedString()
        let attachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "ic_wkb_icon")
        attachment.bounds = CGRect(x: 0, y: -2, width: 28, height: 28)
        let imageAttribute = NSAttributedString(attachment: attachment)
        amountLabelAttribute.append(imageAttribute)
        let textAttribute = NSAttributedString(string: " \(amount + cost)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40)])
        amountLabelAttribute.append(textAttribute)
        amountLabel.attributedText = amountLabelAttribute
    }
    
    private func setupUI() {
        // 转账
        transferButton.setBackgroundImage(normalColorImage, for: .normal)
        transferButton.setBackgroundImage(disabledColorImage, for: .disabled)
        transferButton.layer.borderWidth = 1.0
        transferButton.layer.borderColor = bordColor.cgColor
        transferButton.layer.cornerRadius = transferButton.height * 0.5
        transferButton.layer.masksToBounds = true
        // 确认密码
        confirmPwdButton.setBackgroundImage(normalColorImage, for: .normal)
        confirmPwdButton.setBackgroundImage(disabledColorImage, for: .disabled)
        confirmPwdButton.isEnabled = false
        confirmPwdButton.layer.borderWidth = 1.0
        confirmPwdButton.layer.borderColor = bordColor.cgColor
        confirmPwdButton.layer.cornerRadius = confirmPwdButton.height * 0.5
        confirmPwdButton.layer.masksToBounds = true
        confirmPwdButton.addTarget(self, action: #selector(clickedConfirmPwdBtn), for: .touchUpInside)
        
        passwordTextField.addTarget(self, action: #selector(observeConfirmButtonState), for: .editingChanged)
        passwordTextField.delegate = self
    }

    @IBAction func clickedCloseBtn() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clicckedTransferBtn() {
        UIView.animate(withDuration: 0.5, animations: {
            self.inputViewLeadingConstraint.constant = -self.view.width
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            self.passwordTextField.becomeFirstResponder()
        })
    }
    
    @IBAction func clickedReturnBtn() {
        passwordTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.inputViewLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func clickedConfirmPwdBtn() {
        guard let password = passwordTextField.text else {
            SVProgressHUD.showError(withStatus: "密码不能为空！")
            return
        }
        passwordTextField.resignFirstResponder()
        delegate?.confirmTransaction(viewController: self, password: password)
    }
    
    @objc private func observeConfirmButtonState() {
        guard let password = passwordTextField.text, password.count >= 8 else {
            confirmPwdButton.isEnabled = false
            return
        }
        confirmPwdButton.isEnabled = true
    }
}

extension ConfirmTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        clickedConfirmPwdBtn()
        return true
    }
}
