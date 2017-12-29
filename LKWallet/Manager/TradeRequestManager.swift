//
//  TradeRequestManager.swift
//  LKWallet
//
//  Created by Hao Wang on 28/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import Alamofire

class TradeRequestManager {
    
    static let shared = TradeRequestManager()
    private init() { }
    
    var defaultPerNumber = 20
    
    func fetchTradeRecords(with account: Account, currentPage: Int, completion: ((Int, [Trade]?, NetError?) -> Void)?) {
        let url = baseWalletURL + "/getTransactionRecords"
        let text = ["\(account.address)","0","0","\(currentPage)","\(defaultPerNumber)"]
        TradeNetworkManager.default.session.request(url, method: .post, encoding: JSONStringArrayEncoding(array: text)).responseJSON { (response) in
            if let error = response.error {
                completion?(0, nil, NetError.network("请求返回错误！Error: \(error.localizedDescription)"))
                return
            }
            guard let data = response.result.value as? [String: Any], let result = data["result"] as? [[String: Any]], let totalCount = data["totalnum"] as? Int else {
                completion?(0, nil, NetError.data("数据解析错误！"))
                return
            }
            let page = ceil(Double(totalCount) / Double(self.defaultPerNumber))
            let trades = result.map(Trade.init)
            completion?(Int(page), trades, nil)
        }
    }
    
}
