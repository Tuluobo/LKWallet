//
//  AboutViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 27/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD
import Alamofire

#if DEBUG
    private let receiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
#else
    private let receiptURL = "https://buy.itunes.apple.com/verifyReceipt"
#endif

class AboutViewController: BaseTableViewController {
    
    deinit {
        productRequest?.delegate = nil
        productRequest?.cancel()
        SKPaymentQueue.default().remove(self)
    }
    
    @IBOutlet weak var versionLabel: UILabel!
    private var productRequest: SKProductsRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TraceManager.shared.traceEvent(event: "about_enter")
        
        self.navigationItem.title = "设置"
        let info = Bundle.main.infoDictionary
        versionLabel.text = "\(info?["CFBundleShortVersionString"] ?? "0.1") Build \(info?["CFBundleVersion"] ?? 1)"
        
        SKPaymentQueue.default().add(self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.item {
        case 1:
            self.removeAd()
        case 2:
            self.joinGroup()
        case 3:
            self.openHelp()
        case 4:
            self.mark()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 150
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        let view = UIView()
        
        let imageView = UIImageView(image: UIImage(named: "app_icon"))
        view.addSubview(imageView)
        let label = UILabel()
        view.addSubview(label)
        label.textAlignment = .center
        label.text = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
        }
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "@Copyright 2017"
        }
        return nil
    }
    
    private func mark() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            let appStoreURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&id=1302778851"
            if let url = URL(string: appStoreURL) {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    private func joinGroup() {
        let groupId = "570190348"
        let groupKey = "421e6486c6e8c5a65231a951e5456bbaee3122dfae8d7ede1ca7d8a7bcead9d8"
        let urlStr = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=\(groupId)&key=\(groupKey)&card_type=group&source=external"
        guard let url = URL(string: urlStr) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func openHelp() {
        
    }
    
    private func removeAd() {
        if SKPaymentQueue.canMakePayments() {
            self.requestRemoveAdProduct()
        } else {
            SVProgressHUD.showError(withStatus: "您的设备没有开启应用内购买！")
        }
    }
    
    private func requestRemoveAdProduct() {
        SVProgressHUD.show()
        productRequest = SKProductsRequest(productIdentifiers: [kRemoveAdProductKey])
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    private func verifyPurchaseWithPaymentTransaction(compeletion: ((Bool) -> Void)?) {
        // 从沙盒中获取交易凭证并且拼接成请求体数据
        guard let receiptUrl = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptUrl) else {
            return
        }
        let receiptString = receiptData.base64EncodedString(options: .endLineWithLineFeed)
        let bodyString = ["receipt-data": receiptString]
        Alamofire.request(receiptURL, method: .post, parameters: bodyString, encoding: JSONEncoding.default).responseJSON { (response) in
            guard let result = response.result.value as? [String: Any],
                let status = result["status"] as? Int, status == 0 else {
                    compeletion?(false)
                    return
            }
            guard let receiptDict = result["receipt"] as? [String: Any],
                let inAppDict = (receiptDict["in_app"] as? [[String: Any]])?.first,
                let proIdentifier = inAppDict["product_id"] as? String,
                proIdentifier == kRemoveAdProductKey else {
                    compeletion?(false)
                    return
            }
            compeletion?(true)
        }
    }
    
}

//MARK: - SKProductsRequestDelegate
extension AboutViewController: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        guard products.count > 0 else {
            SVProgressHUD.showError(withStatus: "目前不能移除广告！")
            return
        }
        guard let adProduct = products.first(where: { (product) -> Bool in
            product.productIdentifier == kRemoveAdProductKey
        }) else {
            SVProgressHUD.showError(withStatus: "请求服务不在服务区！")
            return
        }
        let payAlert = UIAlertController(title: adProduct.localizedTitle, message: adProduct.localizedDescription + "\n费用：\(adProduct.price)元" , preferredStyle: .alert)
        payAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        payAlert.addAction(UIAlertAction(title: "确认移除", style: .default, handler: { (_) in
            SKPaymentQueue.default().add(SKPayment(product: adProduct))
            SVProgressHUD.show()
        }))
        payAlert.addAction(UIAlertAction(title: "恢复购买", style: .default, handler: { (_) in
            SKPaymentQueue.default().restoreCompletedTransactions()
            SVProgressHUD.show()
        }))
        self.present(payAlert, animated: true, completion: nil)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        request.delegate = nil
        request.cancel()
        SVProgressHUD.showError(withStatus: "Apple 服务不在服务区！")
    }
    
    func requestDidFinish(_ request: SKRequest) {
        request.delegate = nil
        request.cancel()
        SVProgressHUD.dismiss()
    }
}

//MARK: - SKPaymentTransactionObserver
extension AboutViewController: SKPaymentTransactionObserver {
    // 监听购买结果
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased, .restored:
                self.verifyPurchaseWithPaymentTransaction { (success) in
                    if success {
                        UserDefaults.standard.set(true, forKey: kRemoveAdProductKey)
                        self.isHiddenAdBanner.value = true
                        SVProgressHUD.showSuccess(withStatus: "广告去除成功！")
                    } else {
                        SVProgressHUD.showError(withStatus: "购买验证失败，如果您确实支付成功，请选择恢复购买！")
                    }
                    queue.finishTransaction(transaction)
                }
            case .failed:
                queue.finishTransaction(transaction)
                SVProgressHUD.showError(withStatus: "移除广告失败！")
            case .deferred, .purchasing:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        SVProgressHUD.showError(withStatus: "\(error.localizedDescription)")
    }
}
