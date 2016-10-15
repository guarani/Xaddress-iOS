//
//  XAState.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit

class XAState: CustomStringConvertible {
    
    init(shortName: String?, longName: String?) {
        self.shortName = shortName
        self.longName = longName
    }
    
    var shortName: String?
    var longName: String?
    
    var description: String {
        var des = ""
        if let name = longName {
            des += name
        }
        if let name = shortName {
            des += ", " + name
        }
        return des
    }
}
