//
//  EditAccountViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 10/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditAccountViewController: BaseTableViewController {
    
    var account: Account?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "编辑账户"
        
        setupAccount()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    private func setupAccount() {
        guard let account = account else {
            SVProgressHUD.showError(withStatus: "账户异常！")
            self.navigationController?.popViewController(animated: true)
            return
        }
        nameTextField.text = account.name
        addressTextField.text = account.address
        if account.hasWallet {
            addressTextField.isEnabled = false
        }
        
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func clickedConfirmBtn() {
        
        guard let accountName = self.nameTextField.text, accountName.count > 0 else {
            SVProgressHUD.showError(withStatus: "账户名称不能为空！")
            return
        }
        guard let accountAddress = self.addressTextField.text, accountAddress.count > 0 else {
            SVProgressHUD.showError(withStatus: "账户地址不能为空！")
            return
        }
        account?.name = accountName
        account?.address = accountAddress
        guard let account = account, AccountManager.manager.verify(account: account) else {
            SVProgressHUD.showError(withStatus: "地址格式不正确，请仔细检查！")
            return
        }
        if AccountManager.manager.add(accounts: [account]) {
            NotificationCenter.default.post(name: Notification.Name(kAccountChangeNotification), object: nil)
            SVProgressHUD.showSuccess(withStatus: "账户修改成功！")
        } else {
            SVProgressHUD.showError(withStatus: "账户修改失败！")
        }
        self.navigationController?.popViewController(animated: true)
    }
}

