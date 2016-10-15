//
//  XAAddress.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit

class Xaddress: CustomStringConvertible {
    var n: Int?
    var p1: String?
    var p2: String?
    var word1List = [[String: String]]()
    var word2List = [[String: String]]()
    var country: XACountry?
    var state: XAState?
    
    var description: String {
        return "\(n) \(p2) \(p1)"
    }
    
    var p1Encoded: String? {
        return p1?.xa_encode()
    }
    
    var p2Encoded: String? {
        return p2?.xa_encode()
    }
}
