//
//  AccountViewModel.swift
//  LKWallet
//
//  Created by Hao Wang on 2017/11/18.
//  Copyright © 2017年 Tuluobo. All rights reserved.
//

import Foundation
import ReactiveSwift

class AccountViewModel {
    
    let account: Account
    let amountAction: Action<(), Double, OneError>
    let qrImage: UIImage?
    init(account: Account) {
        self.account = account
        self.amountAction = Action { () -> SignalProducer<Double, OneError> in
            return SignalProducer { (observer, _) in
                EthereumManager.shared.getBalance(with: account) { (result) in
                    switch result {
                    case .failure(let error):
                        observer.send(error: error)
                    case .success(let amount):
                        observer.send(value: amount)
                        observer.sendCompleted()
                    }
                }
            }
        }
        self.qrImage = UIImage.createQRImage(string: account.address)
    }
    
    func cellClass() -> AccountListCell.Type {
        return AccountListCell.self
    }
}

extension AccountViewModel: Equatable {
    static func ==(lhs: AccountViewModel, rhs: AccountViewModel) -> Bool {
        return lhs.account == rhs.account
    }
}
