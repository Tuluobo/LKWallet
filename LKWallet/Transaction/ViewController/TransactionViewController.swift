//
//  TransactionViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 27/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit
import SVProgressHUD
import SnapKit
import ReactiveCocoa
import ReactiveSwift
import MJRefresh

private let kTradeCellKey = "kTradeCellKey"

class TransactionViewController: BaseTableViewController {
    
    var account: Account?
    
    fileprivate var viewModel: TransactionViewModel?
    fileprivate lazy var emptyView: UIView = self.createEmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TraceManager.shared.traceEvent(event: "account_detail_enter", properties: ["account": account?.dictionary() ?? []])
        
        self.navigationItem.title = self.account?.name ?? "账户出错"
        self.view.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.equalToSuperview()
            make.height.equalTo(120)
        }
        let _viewModel = TransactionViewModel(account: account)
        self.emptyView.reactive.isHidden <~ _viewModel.isEmpty.producer.map { !$0 }
        self.viewModel = _viewModel
        setupRefresh()
    }
    
    private func setupRefresh() {
        // set header
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.viewModel?.refresh(type: .down, completion: { (status) in
                self?.tableView.mj_header.endRefreshing()
                switch status {
                case .success, .noMore:
                    self?.tableView.reloadData()
                case .failed(let msg):
                    SVProgressHUD.showError(withStatus: msg)
                }
            })
        })
        // set footer
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.viewModel?.refresh(type: .up, completion: { (status) in
                switch status {
                case .failed(let msg):
                    SVProgressHUD.showError(withStatus: msg)
                    self?.tableView.mj_footer.endRefreshing()
                case .noMore:
                    self?.tableView.reloadData()
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                case .success:
                    self?.tableView.reloadData()
                    self?.tableView.mj_footer.endRefreshing()
                    
                }
            })
        })
        self.tableView.mj_footer.isAutomaticallyHidden = true
        // enter refresh
        self.tableView.mj_header.beginRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.trades.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kTradeCellKey, for: indexPath) as? TransactionListCell else {
            return UITableViewCell()
        }
        cell.trade = viewModel?.trades[indexPath.item]
        return cell
    }
    
    @IBAction func clickedMoreBtn(_ sender: UIBarButtonItem) {
        guard let account = account else {
            SVProgressHUD.showError(withStatus: "账户异常，请稍后再试！")
            return
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "编辑账户", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: kEditAccountSegueKey, sender: nil)
        }))
        if account.hasWallet {
            actionSheet.addAction(UIAlertAction(title: "导出账户文件", style: .default, handler: { [weak self] (_) in
                self?.exportWallet()
            }))
            actionSheet.addAction(UIAlertAction(title: "修改账户密码", style: .default, handler: { (_) in
                self.performSegue(withIdentifier: kResetPasswdSegueKey, sender: nil)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    /// 分享导出
    private func exportWallet() {
        
        guard let account = account else {
            SVProgressHUD.showError(withStatus: "账户异常，请稍后再试！")
            return
        }
        switch OneKeyStore().export(account: account) {
        case .success(let path):
            let fileURL = URL(fileURLWithPath: path)
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.permittedArrowDirections = .any
            }
            self.present(activityVC, animated: true, completion: nil)
        case .failure(let error):
            SVProgressHUD.showError(withStatus: "账户异常，请重新尝试！Error: \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        if identifier == kEditAccountSegueKey {
            if let vc = segue.destination as? EditAccountViewController {
                vc.account = account
            }
        } else if identifier == kResetPasswdSegueKey {
            if let vc = segue.destination as? ResetPasswdTableViewController {
                vc.account = account
            }
        }
    }
}

extension TransactionViewController {
    fileprivate func createEmptyView() -> UIView {
        let view = UIView()
        let emptyLabel = UILabel()
        emptyLabel.text = "暂无交易"
        emptyLabel.textAlignment = .center
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        let emptyImageView = UIImageView(image: UIImage(named: "ic_empty"))
        view.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(emptyLabel.snp.top).offset(-10)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        return view
    }
}
