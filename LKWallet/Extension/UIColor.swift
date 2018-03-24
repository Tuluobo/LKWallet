//
//  UIColor.swift
//  LKWallet
//
//  Created by Hao Wang on 24/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        guard !hex.isEmpty else { return nil }
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") {
            hex = hex.substring(from: "#") ?? ""
        }
        if hex.hasPrefix("0x") {
            hex = hex.substring(from: "0x") ?? ""
        }
        guard !hex.isEmpty else { return nil }
        if hex.count == 6 {
            var rgb: UInt32 = 0
            Scanner(string: hex).scanHexInt32(&rgb)
            self.init(rgb: rgb)
        } else if hex.count == 8 {
            var rgba: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&rgba)
            self.init(rgba: rgba)
        } else {
            return nil
        }
    }
    
    convenience init(rgb: UInt32, a: UInt32) {
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x0000FF) / 255.0,
                  alpha: CGFloat(a & 0x0000FF) / 255.0
        )
    }
    
    convenience init(rgb: UInt32) {
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0)
        )
    }
    
    convenience init(rgba: UInt64) {
        self.init(red: CGFloat((rgba & 0xFF000000) >> 24) / 255.0,
                  green: CGFloat((rgba & 0x00FF0000) >> 16) / 255.0,
                  blue: CGFloat((rgba & 0x0000FF00) >> 8) / 255.0,
                  alpha: CGFloat(rgba & 0x000000FF) / 255.0
        )
    }
}
