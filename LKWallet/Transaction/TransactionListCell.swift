//
//  TransactionListCell.swift
//  LKWallet
//
//  Created by Hao Wang on 28/10/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit

class TransactionListCell: UITableViewCell {
    
    var trade: Trade? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tradeAccountLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    fileprivate func updateUI() {
        typeImageView.image = #imageLiteral(resourceName: "tradein")
        timeLabel.text = nil
        amountLabel.text = nil
        tradeAccountLabel.text = nil
        costLabel.text = nil
        
        guard let trade = self.trade else { return }
        switch trade.type {
        case .in:
            self.typeImageView.image = #imageLiteral(resourceName: "tradein")
        case .out:
            self.typeImageView.image = #imageLiteral(resourceName: "tradeout")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(trade.timestamp)))
        timeLabel.text = dateString
        amountLabel.text = "\(trade.amount)"
        tradeAccountLabel.text = trade.tradeAccount
        costLabel.text = "\(trade.cost)"
    }
}
