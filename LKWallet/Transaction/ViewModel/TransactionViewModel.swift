//
//  TransactionViewModel.swift
//  LKWallet
//
//  Created by Hao Wang on 11/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Foundation
import ReactiveSwift

enum PullType {
    case up     //> 上拉
    case down   //> 下拉
}

enum LoadStatus {
    case success
    case failed(String)
    case noMore
}

class TransactionViewModel {
    
    private let account: Account?
    
    private var totalPage = 1
    private var currentPage = 1
    var trades = [Trade]()
    var isEmpty =  MutableProperty<Bool>(false)
    
    init(account: Account?) {
        self.account = account
    }
    
    func refresh(type: PullType, completion: ((LoadStatus) -> Void)?) {
        guard let account = account else {
            completion?(.failed("账号信息不存在！"))
            return
        }
        self.currentPage = (type == .up) ? currentPage + 1 : 1
        TradeRequestManager.shared.fetchTradeRecords(with: account, currentPage: currentPage) { [weak self] (totalPage, data, error) in
            guard let `self` = self else {
                completion?(.failed("未知异常！"))
                return
            }
            if let err = error {
                completion?(.failed("\(err.localizedDescription)"))
                return
            }
            guard let trades = data else {
                completion?(.failed("获取数据错误！"))
                return
            }
            self.isEmpty.value = totalPage == 0
            self.totalPage = totalPage
            if type == .up {
                self.trades = self.merge(arr1: self.trades, arr2: trades)
            } else {
                self.trades = self.merge(arr1: trades, arr2: self.trades)
            }
            if totalPage <= self.currentPage {
                self.currentPage = totalPage
                completion?(.noMore)
            } else {
                completion?(.success)
            }
        }
    }
    
    func merge(arr1: [Trade], arr2: [Trade]) -> [Trade] {
        guard let last = arr1.last else {
            return arr2
        }
        var index = 0
        for item in arr2 {
            if item.timestamp <= last.timestamp && item.hash != last.hash {
                break
            }
            index += 1
        }
        return arr1 + arr2[index...]
    }
}
