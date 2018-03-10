//
//  ResetPasswdTableViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 10/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import SVProgressHUD

class ResetPasswdTableViewController: BaseTableViewController {
    
    var account: Account?
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newRePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "修改钱包密码"
        guard let account = account, AccountManager.manager.verify(account: account), account.hasWallet else {
            SVProgressHUD.showError(withStatus: "账户异常！")
            self.navigationController?.popViewController(animated: true)
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    @IBAction func clickedCreateBtn() {
        guard let oldPassword = oldPasswordTextField.text else {
            SVProgressHUD.showError(withStatus: "旧密码不能为空！")
            return
        }
        guard let newPassword = newPasswordTextField.text else {
            SVProgressHUD.showError(withStatus: "新密码不能为空！")
            return
        }
        guard let newRePassword = newRePasswordTextField.text else {
            SVProgressHUD.showError(withStatus: "新确认密码不能为空！")
            return
        }
        guard newPassword == newRePassword else {
            SVProgressHUD.showError(withStatus: "两次输入新密码不一致！")
            return
        }
        
        guard oldPassword.count > 7, newPassword.count > 7, newRePassword.count > 7 else {
            SVProgressHUD.showError(withStatus: "密码长度应保持至少8位！")
            return
        }
        guard let account = account else {
            return
        }
        let updateResult = OneKeyStore().updateAccount(account: account, password: oldPassword, newPassword: newPassword)
        switch updateResult {
        case .success:
            SVProgressHUD.showSuccess(withStatus: "密码修改成功，请及时备份文件！")
        case .failure(let error):
            SVProgressHUD.showError(withStatus: "\(error.errorDescription)")
        }
        self.navigationController?.popViewController(animated: true)
    }
}
