//
//  AddAccountViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 27/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddAccountViewController: BaseTableViewController {

    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TraceManager.shared.traceEvent(event: "add_account_enter")
        
        self.title = "添加账号"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    @IBAction func clearAllDidClick() {
        accountNameTextField.text = ""
        accountTextField.text = ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func saveDidClick() {
        guard let address = accountTextField.text, address.count > 0 else {
            SVProgressHUD.showError(withStatus: "账号不能为空！")
            return
        }
        let account = Account(name: accountNameTextField.text, address: address)
        guard AccountManager.manager.verify(account: account) else {
            SVProgressHUD.showError(withStatus: "账号格式不正确！")
            return
        }
        
        if AccountManager.manager.queryAllAccount().contains(account) {
            SVProgressHUD.showError(withStatus: "此账号已添加！")
            return
        }
        
        if AccountManager.manager.add(accounts: [account]) {
            SVProgressHUD.showSuccess(withStatus: "账号添加成功！")
            self.navigationController?.popViewController(animated: true)
        } else {
            SVProgressHUD.showError(withStatus: "账号保存失败！")
        }
    }

}
