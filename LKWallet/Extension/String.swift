//
//  String.swift
//  LKWallet
//
//  Created by Hao Wang on 24/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import Foundation

protocol Emptable {
    var isEmpty: Bool { get }
}

extension String: Emptable {
    var isEmpty: Bool {
        return self.count == 0
    }
}

extension Swift.Optional where Wrapped: Emptable {
    var isEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension String {
    
    func substring(from string: String) -> String? {
        guard let range = self.range(of: string) else { return nil }
        return self.substring(from: range.upperBound)
    }
    
    func substring(to string: String) -> String? {
        guard let range = self.range(of: string) else { return nil }
        return self.substring(to: range.lowerBound)
    }
}
