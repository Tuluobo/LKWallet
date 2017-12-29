//
//  EthereumManager.swift
//  LKWallet
//
//  Created by Hao Wang on 17/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import Geth
import Result
import CryptoSwift

enum OneError: Error {
    case failedAccount
    case otherError(Error)
    
    var errorDescription: String {
        switch self {
        case .failedAccount:
            return "账户地址错误！"
        case .otherError(let error):
            return error.localizedDescription
        }
    }
}


class EthereumManager {
    
    static let shared = EthereumManager()
    
    private let CLIENT_API = "https://walletapi.onethingpcs.com"
    private let mclient: GethEthereumClient
    private init() {
        GethSetVerbosity(5)
        self.mclient = GethEthereumClient(CLIENT_API)
    }
    
    func getBalance(with account: Account, completion: ((Result<Double, OneError>) -> Void)?) {
        let conetext = GethContext()
        guard let address = GethAddress(fromHex: account.address) else {
            completion?(.failure(.failedAccount))
            return
        }
        DispatchQueue.global().async {
            do {
                let balance = try self.mclient.getBalanceAt(conetext, account: address, number: -1)
                DispatchQueue.main.async {
                    guard let balanceBytes = balance.getBytes() else {
                        completion?(.success(0))
                        return
                    }
                    completion?(.success(Double(hexString: "0x\(balanceBytes.toHexString())")))
                }
            } catch{
                DispatchQueue.main.async {
                    completion?(.failure(.otherError(error)))
                }
            }
        }
    }
}


