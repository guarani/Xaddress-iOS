//
//  Utils.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 11/5/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
}


extension UIView {
    func addBorder() {
        layer.cornerRadius = 10
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSizeZero
        layer.borderWidth = 3
        layer.borderColor = Constant.Color.Border.CGColor
    }
}