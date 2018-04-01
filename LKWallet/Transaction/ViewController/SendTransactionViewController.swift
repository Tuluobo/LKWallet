//
//  SendTransactionViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 24/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import ReactiveSwift
import SVProgressHUD
import PopupController

class SendTransactionViewController: BaseViewController {

    var transferAccount: Account?
    
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var transAddressTextView: UITextView!
    @IBOutlet weak var amountTextField: UITextField!
    
    private var receiveAccount: Account?
    private var amount: Double = 0
    private var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transferButton.setBackgroundImage(normalColorImage, for: .normal)
        transferButton.setBackgroundImage(disabledColorImage, for: .disabled)
        transferButton.isEnabled = false
        
        transAddressTextView.delegate = self
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(observeTransferButtonState), for: .editingChanged)
    }

    @IBAction func clickedCloseBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedTransferButton() {
        performSegue(withIdentifier: kConfirmPasswordSegueKey, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == kQRCodeAddSegueKey, let qrCodeVC = segue.destination as? QRCodeViewController {
            qrCodeVC.delegate = self
        } else if identifier == kConfirmPasswordSegueKey,
            let navigationVC = segue.destination as? UINavigationController, let confirmVc = navigationVC.topViewController as? ConfirmTransactionViewController {
            navigationVC.modalPresentationStyle = .custom
            confirmVc.transferAccount = transferAccount
            confirmVc.receiveAccount = receiveAccount
            confirmVc.amount = amount
            confirmVc.delegate = self
        } else if identifier == kTransactionResultSegueKey, let resultVC = segue.destination as? TransactionResultViewController {
            resultVC.transferAccount = transferAccount
            resultVC.receiveAccount = receiveAccount
            resultVC.password = password
            resultVC.amount = amount
        }
    }
    
    // MARK: - Private
    
    @objc private func observeTransferButtonState() {
        if let address = transAddressTextView.text,
            AccountManager.manager.verify(account: Account(name: nil, address: address)),
            let amountText = amountTextField.text,
            let amount = Double(amountText), amount > 0 {
            transferButton.isEnabled = true
            self.receiveAccount = Account(name: nil, address: address)
            self.amount = amount
        } else {
            transferButton.isEnabled = false
            self.receiveAccount = nil
            self.amount = 0
        }
    }
}

extension SendTransactionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        observeTransferButtonState()
    }
}

extension SendTransactionViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{
            return true
        }
        let textLength = text.count + string.count - range.length
        return textLength <= 8
    }
}

extension SendTransactionViewController: QRCodeViewControllerDelegate {
    func handleQRData(viewController: QRCodeViewController, string: String?) {
        guard let address = string, AccountManager.manager.verify(account: Account(name: nil, address: address)) else {
            SVProgressHUD.showError(withStatus: "账户地址不正确！")
            return
        }
        transAddressTextView.text = address
        observeTransferButtonState()
    }
}

extension SendTransactionViewController: ConfirmTransactionViewControllerDelegate {
    func confirmTransaction(viewController: ConfirmTransactionViewController, password: String) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }
            self.password = password
            self.performSegue(withIdentifier: kTransactionResultSegueKey, sender: nil)
         }
    }
}
