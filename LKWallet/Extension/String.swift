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

extension String: Emptable { }

extension Swift.Optional where Wrapped: Emptable {
    var isEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension String {
    
    func substring(from string: String) -> String? {
        guard let range = self.range(of: string) else { return nil }
        return String(self[range.upperBound...])
    }
    
    func substring(to string: String) -> String? {
        guard let range = self.range(of: string) else { return nil }
        return String(self[..<range.lowerBound])
    }

}
