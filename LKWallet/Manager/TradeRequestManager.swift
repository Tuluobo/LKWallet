//
//  TradeRequestManager.swift
//  LKWallet
//
//  Created by Hao Wang on 28/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import Alamofire

private let baseWalletURL = "https://walletapi.onethingpcs.com"

public enum NetError: Error {
    case network(String?)
    case data(String?)
    case unknow(String?)
    
    var localizedDescription: String {
        var message: String?
        switch self {
            case .network(let msg):
                message = msg
            case .data(let msg):
                message = msg
            case .unknow(let msg):
                message = msg
        }
        return message ?? "未知原因(-1)"
    }
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
        headers["User-Agent"] = "OneWallet/1.2.0 (iPhone; iOS 11.3; Scale/3.00)"
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
    
    func sendTransactionRequest(with transactionHex: String, completion: ((String?, NetError?) -> Void)?) {
        
        assertionFailure("注意修改此处的代理地址！")
        
        let proxyInfo: [String: Any] = ["HTTPSEnable": true,
                                        "HTTPSProxy": "192.168.1.233",      // 你的海外代理地址
                                        "HTTPSPort" : 1087]                 // 端口
        
        let params: Parameters = ["jsonrpc": "2.0",
                                  "method": "eth_sendRawTransaction",
                                  "params": ["\(transactionHex)"],
                                  "id": 1,
                                  "Nc": "IN"]
        var headers = defaultHeaders
        headers["Nc"] = "IN"
        
        let configuration = Alamofire.SessionManager.default.session.configuration
        configuration.connectionProxyDictionary = proxyInfo
        Alamofire.SessionManager(configuration: configuration).request(baseWalletURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error {
                completion?(nil, NetError.network("请求返回错误！Error: \(error.localizedDescription)"))
                return
            }
            guard let data = response.result.value as? [String: Any] else {
                completion?(nil, NetError.data("服务端数据错误！"))
                return
            }
            if let error = data["error"] as? [String: Any],
                let code = error["code"] as? Int,
                let msg = error["message"] as? String {
                completion?(nil, NetError.data("\(msg)(\(code))"))
                return
            }
            if let result = data["result"] as? String {
                completion?(result, nil)
            }
        }
    }
    
}
