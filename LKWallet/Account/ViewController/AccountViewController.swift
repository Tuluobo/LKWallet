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

private let kAccountListCell = "kAccountListCell"
private let kAccountListToTradeSegue = "kAccountListToTradeSegue"

class AccountViewController: BaseTableViewController {
    
    private var viewModels = [AccountViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TraceManager.shared.traceEvent(event: "account_enter")
        self.navigationItem.title = "玩客钱包"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newViewModels = AccountManager.manager.queryAllAccount().map(AccountViewModel.init)
        if newViewModels != self.viewModels {
            self.viewModels = newViewModels
            TraceManager.shared.traceEvent(event: "account_load_wallet", properties: ["walletTotal": self.viewModels.count])
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = viewModels[indexPath.item]
        if let cell = tableView.dequeueReusableCell(withIdentifier: kAccountListCell, for: indexPath) as? AccountListCell {
            cell.delegate = self
            cell.viewModel = viewModel
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 164.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: kAccountListToTradeSegue, sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.item]
        if editingStyle == .delete {
            if AccountManager.manager.delete(accounts: [viewModel.account]) {
                viewModels.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == kAccountListToTradeSegue {
            if let destVc = segue.destination as? TransactionViewController, let indexPath = sender as? IndexPath {
                destVc.account = viewModels[indexPath.item].account
            }
        }
    }
}

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
}
