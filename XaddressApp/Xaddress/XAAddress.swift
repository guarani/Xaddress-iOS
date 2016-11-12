//
//  XAAddress.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit

class XAAddressComponents: CustomStringConvertible {
    
    var number: String?
    var word1: String?
    var word2: String?
    
    var country: XACountry?
    var state: XAState?
    
    /// word2 can be identified by any one of these nouns.
    var nouns: [XANoun]?
    
    /// word1 can be identified by any one of these nouns.
    var adjectives: [XAAdjective]?
    
    /// An Xaddress is in a geographical area: either a country or a state.
    var isCountry: Bool {
        return country?.kind == "X"
    }
    
    var title: String? {
        if isCountry {
            return country?.name
        } else {
            return state?.name1
        }
    }
    
    var subtitle: String? {
        if isCountry == false {
            return state?.countryName
        }
        return nil
    }
    
    var description: String {
        var desc = ""
        if let number = number {
            desc += "\(number)"
        }
        if let word2 = word2 {
            desc += " \(word2)"
        }
        if let word1 = word1 {
            desc += " \(word1)"
        }
        return desc
    }
}
