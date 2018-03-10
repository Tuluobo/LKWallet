//
//  TradeRequestManager.swift
//  LKWallet
//
//  Created by Hao Wang on 28/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import Alamofire

let baseWalletURL = "https://walletapi.onethingpcs.com"

public enum NetError: Error {
    case network(String?)
    case data(String?)
    case unknow(String?)
}

struct JSONStringArrayEncoding: ParameterEncoding {
    private let array: [String]
    
    init(array: [String]) {
        self.array = array
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest.httpBody = data
        
        return urlRequest
    }
}

class TradeRequestManager {
    
    static let shared = TradeRequestManager()
    private init() { }
    
    var defaultPerNumber = 10
    
    fileprivate var defaultHeaders: HTTPHeaders {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Accept"] = "*/*"
        headers["User-Agent"] = "OneWallet/1.2.0 (iPhone; iOS 11.2; Scale/3.00)"
        headers["Content-Type"] = "application/json"
        headers["Accept-Language"] = "zh-Hans-CN;q=1"
        return headers
    }
    
    func fetchTradeRecords(with account: Account, currentPage: Int, completion: ((Int, [Trade]?, NetError?) -> Void)?) {
        let url = baseWalletURL + "/getTransactionRecords"
        let text = ["\(account.address)","0","0","\(currentPage)","\(defaultPerNumber)"]
        Alamofire.request(url, method: .post, encoding: JSONStringArrayEncoding(array: text), headers: defaultHeaders).responseJSON { (response) in
            if let error = response.error {
                completion?(0, nil, NetError.network("请求返回错误！Error: \(error.localizedDescription)"))
                return
            }
            guard let data = response.result.value as? [String: Any], let totalCount = data["totalnum"] as? Int else {
                completion?(0, nil, NetError.data("服务端数据错误！"))
                return
            }
            // 最后一页没有数据
            let page = Int(ceil(Double(totalCount) / Double(self.defaultPerNumber)))
            if page < currentPage {
                completion?(page, [], nil)
                return
            }
            // 数据
            guard let result = data["result"] as? [[String: Any]] else {
                completion?(0, nil, NetError.data("数据解析错误！"))
                return
            }
            let trades = result.map(Trade.init)
            completion?(Int(page), trades, nil)
        }
    }
    
}
