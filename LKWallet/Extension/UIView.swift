//
//  UIView.swift
//  LKWallet
//
//  Created by Hao Wang on 10/03/2018.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import UIKit

extension UIView {
    
    var width: CGFloat {
        return self.bounds.size.width
    }
    
    var height: CGFloat {
        return self.bounds.size.height
    }
    
    var originX: CGFloat {
        return self.frame.origin.x
    }
    
    var originY: CGFloat {
        return self.frame.origin.y
    }
    
}
