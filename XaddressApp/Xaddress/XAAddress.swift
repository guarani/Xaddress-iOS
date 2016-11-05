//
//  XAAddress.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit

class XAAddressComponents: CustomStringConvertible {
    var number: Int?
    var word1: String?
    var word2: String?
    var country: XACountry?
    var state: XAState?
    
    var description: String {
        return "\(number) \(word2) \(word1)"
    }
}
