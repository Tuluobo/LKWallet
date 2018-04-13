//
//  EthereumManager.swift
//  LKWallet
//
//  Created by Hao Wang on 17/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Geth
import Result

enum OneError: Error {
    case failedAccount
    case failedTransaction
    case otherError(Error)
    
    var localizedDescription: String {
        switch self {
        case .failedAccount:
            return "账户地址错误！"
        case .failedTransaction:
            return "转账异常！"
        case .otherError(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - EthereumManager

class EthereumManager {
    
    static let shared = EthereumManager()
    
    private let CLIENT_API = "https://walletapi.onethingpcs.com"
    private let mclient: GethEthereumClient
    private let keyStore: KeyStore
    private init() {
        GethSetVerbosity(5)
        self.mclient = GethEthereumClient(CLIENT_API)
        self.keyStore = OneKeyStore()
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
    
    func sendTransaction(sourceAccount: Account, passphrase: String, receiveAccount: Account, dealAmount: Double, completion: ((String?, OneError?) -> Void)?) {
        let context = GethContext()
        let sourceAddress = GethAddress(fromHex: sourceAccount.address)
        let receiveAddress = GethAddress(fromHex: receiveAccount.address)
        
        var nonce: Int64 = 0
        do {
            try self.mclient.getNonceAt(context, account: sourceAddress, number: -1, nonce: &nonce)
        } catch {
            completion?(nil, .otherError(error))
            return
        }
        
        guard let transaction = GethTransaction(nonce, to: receiveAddress, amount: GethBigInt(Int64(dealAmount * 1000000000000000000)), gasLimit: 100000, gasPrice: GethNewBigInt(100000000000), data: nil) else {
            completion?(nil, .failedTransaction)
            return
        }
        
        let signedResult = self.keyStore.sign(account: sourceAccount, passphrase: passphrase, tx: transaction, chainID: GethBigInt(30261))
        switch signedResult {
        case .success(let signedTransaction):
            do {
                let signedHex = try signedTransaction.encodeRLP().toHexString()
                TradeRequestManager.shared.sendTransactionRequest(with: "0x" + signedHex, completion: { (txHash, error) in
                    if let error = error {
                        completion?(nil, .otherError(error))
                        return
                    }
                    completion?(txHash, nil)
                })
            } catch {
                completion?(nil, .otherError(error))
                return
            }
        case .failure(let error):
            completion?(nil, .otherError(error))
        }
    }
}


