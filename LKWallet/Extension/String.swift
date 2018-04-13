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
        return String(self[range.upperBound...])
    }
    
    func substring(to string: String) -> String? {
        guard let range = self.range(of: string) else { return nil }
        return String(self[..<range.lowerBound])
    }
    
    public func exchangeCharater(index1: Int, index2: Int) -> String {
        if self.count > index1, self.count > index2 {
            let s1 = self.substring(from: index1, length: 1)
            let s2 = self.substring(from: index2, length: 1)
            var startIndex = self.index(self.startIndex, offsetBy: index2)
            var endIndex = self.index(self.startIndex, offsetBy: index2 + 1)
            var string = self.replacingCharacters(in: startIndex..<endIndex, with: s1)
            startIndex = string.index(self.startIndex, offsetBy: index1)
            endIndex = string.index(self.startIndex, offsetBy: index1 + 1)
            string = string.replacingCharacters(in: startIndex..<endIndex, with: s2)
            return string
        } else {
            return self
        }
    }
    
    public func substring(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex...]
            return String(subString)
        } else {
            return self
        }
    }
    
    public func substring(to index: Int) -> String {
        if self.count > index {
            let endIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[..<endIndex]
            return String(subString)
        } else {
            return self
        }
    }
    
    public func substring(from index1: Int, to index2: Int) -> String {
        if index1 > index2 {
            return self
        } else {
            return self.substring(from: index1, length: index2 - index1)
        }
    }
    
    public func substring(from index: Int, length: Int) -> String {
        if length >= 0 {
            return self.substring(from: index).substring(to: length)
        } else {
            return self
        }
    }
}
