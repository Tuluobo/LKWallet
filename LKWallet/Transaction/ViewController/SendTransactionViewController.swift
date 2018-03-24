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

    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var transAddressTextView: UITextView!
    @IBOutlet weak var amountTextField: UITextField!
    
    private var account: Account?
    private var amount: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let normalColor = UIImage.image(with: UIColor(hex: "#418BF7")!)
        let disabledColor = UIImage.image(with: UIColor(hex: "#418BF7")!.withAlphaComponent(0.4))
        transferButton.setBackgroundImage(normalColor, for: .normal)
        transferButton.setBackgroundImage(disabledColor, for: .disabled)
        transferButton.isEnabled = false
        
        transAddressTextView.delegate = self
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(observeTransferButtonState), for: .editingChanged)
    }

    @IBAction func clickedCloseBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedTransferButton() {
        // TODO
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == kQRCodeAddSegueKey, let qrCodeVC = segue.destination as? QRCodeViewController  {
                qrCodeVC.delegate = self
            }
        }
    }
    
    // MARK: - Private
    
    @objc private func observeTransferButtonState() {
        if let address = transAddressTextView.text,
            AccountManager.manager.verify(account: Account(name: nil, address: address)),
            let amountText = amountTextField.text,
            let amount = Double(amountText), amount > 0 {
            transferButton.isEnabled = true
            self.account = Account(name: nil, address: address)
        } else {
            transferButton.isEnabled = false
            self.account = nil
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
