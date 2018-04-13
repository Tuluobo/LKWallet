//
//  KeyStore.swift
//  WKWallet
//
//  Created by Hao Wang on 14/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import Result
import Geth

enum KeyStoreError: LocalizedError {
    case failedToFindAccount
    case failedToDeleteAccount
    case failedToDecryptKey
    case failed(Error)
    case duplicateAccount
    case failedToSignTransaction
    case failedToUpdatePassword
    case failedToCreateWallet
    case failedToImportPrivateKey
    
    
    var localizedDescription: String {
        switch self {
        case .failedToFindAccount:
            return "未找到对应账户！"
        case .failedToDeleteAccount:
            return "删除账户失败！"
        case .failedToDecryptKey:
            return "密码不正确！"
        case .failed(let error):
            return error.localizedDescription
        case .duplicateAccount:
            return "您已经添加过该账户！"
        case .failedToSignTransaction:
            return "交易签名失败！"
        case .failedToUpdatePassword:
            return "密码修改失败！"
        case .failedToCreateWallet:
            return "钱包创建失败！"
        case .failedToImportPrivateKey:
            return "钱包导入失败！"
        }
    }
}

protocol KeyStore {
    var hasAccounts: Bool { get }
    var accounts: [Account] { get }
    
    func createAccount(with password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void)
    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeyStoreError>
    func importKeystore(path url: URL) -> Result<Account, KeyStoreError>
    func export(account: Account) -> Result<String, KeyStoreError>
    func delete(account: Account) -> Result<Account, KeyStoreError>
    func sign(account: Account, passphrase: String, tx: GethTransaction, chainID: GethBigInt) -> Result<GethTransaction, KeyStoreError>
}
