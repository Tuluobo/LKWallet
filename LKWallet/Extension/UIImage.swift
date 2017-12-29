//
//  UIImage.swift
//  LKWallet
//
//  Created by Hao Wang on 18/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit

extension UIImage {
    // 生成二维码
    static func createQRImage(string: String) -> UIImage? {
        let stringData = string.data(using: .utf8, allowLossyConversion: false)
        //创建一个二维码的滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        guard let qrCIImage = qrFilter?.outputImage else {
            return nil
        }
        
        // 创建一个颜色滤镜， 黑白色
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrCIImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        guard let filterImage = colorFilter.outputImage else {
            return nil
        }
        // 返回二维码image
        return UIImage(ciImage: filterImage.transformed(by: CGAffineTransform(scaleX: 5, y: 5)))
    }
}
