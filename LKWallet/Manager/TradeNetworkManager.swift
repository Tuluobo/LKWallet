//
//  TradeNetworkManager.swift
//  LKWallet
//
//  Created by Hao Wang on 28/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Alamofire

let baseWalletURL = "https://walletapi.onethingpcs.com"

public enum NetError: Error {
    case network(String?)
    case data(String?)
    case unknow(String?)
}

public class TradeNetworkManager {
    
    static let `default` = TradeNetworkManager()
    fileprivate let _sessionManager: SessionManager
    public var session: SessionManager {
        return _sessionManager
    }
    private init() {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["Accept"] = "*/*"
        defaultHeaders["Origin"] = "https://red.xunlei.com"
        defaultHeaders["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_0) AppleWebKit/537.36 (KHTML, like Gecko) OTCWallet/1.1.0 Chrome/58.0.3029.110 Electron/1.7.9 Safari/537.36"
        defaultHeaders["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
        defaultHeaders["Referer"] = "https://red.xunlei.com/"
        defaultHeaders["Accept-Encoding"] = "gzip, deflate"
        defaultHeaders["Accept-Language"] = "en"
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        self._sessionManager = Alamofire.SessionManager(configuration: configuration)
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

