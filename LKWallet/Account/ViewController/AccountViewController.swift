//
//  AccountViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 27/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit
import SVProgressHUD
import PopupController
import MJRefresh

private let kAccountListCell = "kAccountListCell"
private let kAccountListToTradeSegue = "kAccountListToTradeSegue"

class AccountViewController: BaseTableViewController {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var viewModels = [AccountViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TraceManager.shared.traceEvent(event: "account_enter")
        self.navigationItem.title = "玩客钱包"
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlerImport(notification:)), name: NSNotification.Name(kOpenKeyStoreFileNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlerAccountChange), name: NSNotification.Name(kAccountChangeNotification), object: nil)
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadData(isForce: true)
            self?.tableView.mj_header.endRefreshing()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    private func loadData(isForce: Bool = false) {
        let newViewModels = AccountManager.manager.queryAllAccount().map(AccountViewModel.init)
        if isForce || newViewModels != self.viewModels {
            self.viewModels = newViewModels
            TraceManager.shared.traceEvent(event: "account_load_wallet", properties: ["walletTotal": self.viewModels.count])
            tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = viewModels[indexPath.section]
        if let cell = tableView.dequeueReusableCell(withIdentifier: kAccountListCell, for: indexPath) as? AccountListCell {
            cell.delegate = self
            cell.viewModel = viewModel
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let viewModel = viewModels[indexPath.section]
        return viewModel.cellClass().preferredDimension(for: viewModel, in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20.0
        }
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (viewModels.count - 1) {
            return 20.0
        }
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.section]
        if editingStyle == .delete {
            if AccountManager.manager.delete(accounts: [viewModel.account]) {
                viewModels.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .fade)
            } else {
                SVProgressHUD.showError(withStatus: "删除失败！")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: kAccountListToTradeSegue, sender: indexPath)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == kAccountListToTradeSegue {
            if let destVc = segue.destination as? TransactionViewController, let indexPath = sender as? IndexPath {
                destVc.account = viewModels[indexPath.section].account
            }
        }
    }
    
    @IBAction func clickedAddButton(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "添加账户", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: kAddAccountSegueKey, sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "创建新账户", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: kCreateAccountSegueKey, sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "导入原有账户", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: kImportAccountSegueKey, sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - 导入
extension AccountViewController {
    @objc private func handlerImport(notification: Notification) {
        guard let userinfo = notification.userInfo as? [String: Any], let url = userinfo["fileUrl"] as? URL else {
            return
        }
        let alertVc = UIAlertController(title: nil, message: "是否导入该文件？", preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "导入", style: .default, handler: { (_) in
            self.importKeyStoreFile(url: url)
        }))
        alertVc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertVc, animated: true, completion: nil)
    }
    
    private func importKeyStoreFile(url: URL) {
        let result = OneKeyStore().importKeystore(path: url)
        switch result {
        case .success(let account):
            var info = "导入成功！"
            if AccountManager.manager.queryAllAccount().contains(account) {
                info += "并替换为有文件的账户！"
            }
            if AccountManager.manager.add(accounts: [account]) {
                SVProgressHUD.showSuccess(withStatus: info)
                loadData(isForce: true)
            } else {
                SVProgressHUD.showSuccess(withStatus: "导入失败！")
            }
            self.navigationController?.popToRootViewController(animated: true)
        case .failure(let error):
            SVProgressHUD.showError(withStatus: "\(error.localizedDescription)")
        }
    }
}

// MARK: - 账户改变
extension AccountViewController {
    @objc private func handlerAccountChange() {
        loadData(isForce: true)
    }
}

// MARK: - 二维码
extension AccountViewController: AccountListCellDelegate {
    
    func accountListCell(_ cell: AccountListCell, show qrImage: UIImage) {
        _ = PopupController
            .create(self.navigationController ?? self)
            .customize(
                [
                    .animation(.slideUp),
                    .dismissWhenTaps(true)
                ]
            )
            .show(QRShowViewController(image: qrImage))
    }
    
    func accountListCell(_ cell: AccountListCell, clickedTransactionWith account: Account) {
        guard let navigationVC = UIStoryboard(name: "Transfer", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let sendTransactionVC = navigationVC.topViewController as? SendTransactionViewController else {
            return
        }
        sendTransactionVC.transferAccount = account
        self.navigationController?.present(navigationVC, animated: true, completion: nil)
    }
}

