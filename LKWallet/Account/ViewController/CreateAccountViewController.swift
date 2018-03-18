//
//  CreateAccountViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 18/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit
import Result
import SVProgressHUD

class CreateAccountViewController: BaseTableViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "创建钱包"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    @IBAction func clickedCreateBtn() {
        guard let password = passwordTextField.text else {
            SVProgressHUD.showError(withStatus: "密码不能为空！")
            return
        }
        guard let repassword = rePasswordTextField.text else {
            SVProgressHUD.showError(withStatus: "确认密码不能为空！")
            return
        }
        guard password == repassword else {
            SVProgressHUD.showError(withStatus: "两次输入密码不一致！")
            return
        }
        
        guard password.count > 7, repassword.count > 7 else {
            SVProgressHUD.showError(withStatus: "密码长度应保持至少8位！")
            return
        }
        SVProgressHUD.show()
        OneKeyStore().createAccount(with: password) { (result) in
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: kCreateAccountResultSegueKey, sender: result)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == kCreateAccountResultSegueKey {
            if let vc = segue.destination as? CreateResultViewController, let result = sender as? Result<Account, KeyStoreError> {
                vc.createResult = result
            }
        }
    }
}
