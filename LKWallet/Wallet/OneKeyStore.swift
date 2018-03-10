//
//  OneKeyStore.swift
//  WKWallet
//
//  Created by Hao Wang on 14/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import Result
import Geth
import CryptoSwift

class OneKeyStore: KeyStore {
    
    var hasAccounts: Bool {
        return !accounts.isEmpty
    }
    var accounts: [Account] {
        return self.gethAccounts.map(Account.init)
    }
    
    private var gethAccounts: [GethAccount] {
        var finalAccounts: [GethAccount] = []
        let allAccounts = gethKeyStorage.getAccounts()
        let size = allAccounts?.size() ?? 0
        
        for i in 0..<size {
            if let account = try! allAccounts?.get(i) {
                finalAccounts.append(account)
            }
        }
        return finalAccounts
    }
    
    private let gethKeyStorage: GethKeyStore
    private let dataDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private let keydir: String
    init(keyStoreSubfolder: String = "/Keystores") {
        self.keydir = dataDir + keyStoreSubfolder
        self.gethKeyStorage = GethNewKeyStore(keydir, GethLightScryptN, GethLightScryptP)
        if !FileManager.default.fileExists(atPath: self.keydir) {
            do {
                try FileManager.default.createDirectory(atPath: self.keydir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Create Directory Error: \(error.localizedDescription)")
            }
        }
    }
    
    func createAccount(with password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let gethAccount = try! self.gethKeyStorage.newAccount(password)
            let account = Account(name: nil, address: gethAccount.getAddress().getHex().lowercased(), hasWallet: true)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
        
    }
    
    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeyStoreError> {
        switch getGethAccount(for: account) {
        case .success(let gethAccount):
            do {
                try gethKeyStorage.update(gethAccount, passphrase: password, newPassphrase: newPassword)
                return (.success(()))
            } catch {
                return (.failure(.failed(error)))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func importKeystore(path url: URL) -> Result<Account, KeyStoreError> {
        do {
            let data = try Data(contentsOf: url)
            let walletJSON = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            guard let walletObj = walletJSON as? [String: Any], let _address = walletObj["address"] as? String else {
                return .failure(.failedToDecryptKey)
            }
            let address = "0x\(_address)".lowercased()
            //Hack to avoid duplicate accounts
            let accounts = gethAccounts.filter { $0.getAddress().getHex().lowercased() == address.lowercased() }
            if accounts.count > 0 {
                return .failure(.duplicateAccount)
            }
            do {
                try data.write(to: URL(fileURLWithPath: self.keydir + "/" + address))
                let account = Account(name: nil, address: address.lowercased(), hasWallet: true)
                return .success(account)
            } catch {
                return .failure(.failed(error))
            }
        } catch {
            return .failure(.failed(error))
        }
    }
    
    func delete(account: Account) -> Result<Account, KeyStoreError> {
        switch getGethAccount(for: account) {
        case .success(let gethAccount):
            guard let fileURLStr = gethAccount.getURL(), let url = URL(string: fileURLStr) else {
                return .failure(.failedToFindAccount)
            }
            do {
                try FileManager.default.removeItem(atPath: url.path)
                return .success(account)
            } catch {
                return .failure(.failedToFindAccount)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func export(account: Account) -> Result<String, KeyStoreError> {
        switch getGethAccount(for: account) {
        case .success(let gethAccount):
            guard let fileURLStr = gethAccount.getURL(), let url = URL(string: fileURLStr) else {
                return .failure(.failedToFindAccount)
            }
            return .success(url.path)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getGethAccount(for account: Account) -> Result<GethAccount, KeyStoreError> {
        guard let account = gethAccounts.filter({ $0.getAddress().getHex().lowercased() == account.address.lowercased() }).first else {
            return .failure(.failedToFindAccount)
        }
        return .success(account)
    }
    
    func sign(account: Account, passphrase: String, tx: GethTransaction, chainID: GethBigInt) -> Result<GethTransaction, KeyStoreError> {
        switch self.getGethAccount(for: account) {
        case .success(let gethAccount):
            do {
                let signedTransaction = try self.gethKeyStorage.signTxPassphrase(gethAccount, passphrase: passphrase, tx: tx, chainID: chainID)
                return .success(signedTransaction)
            } catch {
                return .failure(.failedToSignTransaction)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
