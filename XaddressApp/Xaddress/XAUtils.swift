//
//  XAUtils.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit
import CoreLocation

typealias XACombinationTableElement = (idx: Int, (lat: Int, lon: Int))
typealias XACombinationTable = [XACombinationTableElement]


extension String {
    
    func xa_address() -> XAAddress? {
        
        let str = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) as NSString
        guard str.length > 0 else { return nil }
        
        let address = XAAddress()
        
        do {
            let regex = try NSRegularExpression(pattern: "(\\w*)\\s*(\\w*)\\s*(\\w*)", options: NSRegularExpressionOptions(rawValue: 0))
            
            let all = NSRange(location: 0, length: self.characters.count)
            var groups = [String]()
            if let result = regex.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: all).first {
                
                for i in 1 ..< result.numberOfRanges {
                    let r = result.rangeAtIndex(i)
                    let s = str.substringWithRange(r)
                    groups.append(s)
                }
            }
            
            guard groups.count > 0 else { return nil }
            
            if let num = Int(groups[0]) {
                address.n = num
                if groups.count == 3 {
                    address.p1 = groups[2]
                    address.p2 = groups[1]
                } else {
                    address.p1 = groups[1]
                }
            } else  {
                if groups.count == 3 {
                    address.p1 = groups[0]
                    address.p2 = groups[1]
                    address.n = Int(groups[2])!
                } else {
                    address.p1 = groups[0]
                    address.n = Int(groups[2])!
                }
            }
            
            print(address)
            return address
        } catch {
            print("Error parsing xaddress string with regex.")
        }
        
        return nil
    }
    
    
    
    func xa_encode() -> String {
        
        // Convert to an array of double ASCII values.
        // e.g. for "PEARL", the result is:
        let nums: [CLLocationDegrees] = self.characters.map {
            let characterString = String($0)
            let scalars = characterString.unicodeScalars
            return CLLocationDegrees(scalars[scalars.startIndex].value)
        }
        
        // Calculate the result by alternatively multiplying/dividing the terms.
        // e.g. for [80.0, 69.0, 65.0, 82.0, 76.0] the operations are equal to: 80/68*65/82*76 = 69.848002831
        let res = nums.enumerate().reduce(1) {
            $1.index % 2 == 0 ? $0 * $1.element : $0 / $1.element
        }
        
        // Get final value (first 4 digits after decimal place).
        // e.g. for 69.848002831 the result is 8480
        // TODO: Swift rounds 90.2584550539029 to 2585, is this correct?
        let final = String(String(format: "%.4f", res).characters.suffix(4))
        
        return final
    }
    
    func xa_combinationTable() -> XACombinationTable {
        
        print("\nCreating combination table for:", self)
        
        // e.g. Maluku, Indonesia has a bounds string of -1.37872@134.908555*-8.345391@125.722838
        // so the components will be:
        // initialLat = -8, initialLon = 125, finalLat = -1, finalLon = 134
        var initialLat: Int!
        var initialLon: Int!
        var finalLat: Int!
        var finalLon: Int!
        
        do {
            let regex = try NSRegularExpression(pattern: "[+-]?\\d*\\.?\\d+", options: NSRegularExpressionOptions(rawValue: 0))
            let options = NSMatchingOptions(rawValue: 0)
            let range = NSRange(location: 0, length: self.characters.count)
            
            // e.g. -8, 125, -1, 134
            let integers: [Int] = regex.matchesInString(self, options: options, range: range).map { result in
                let r = result.rangeAtIndex(0)
                let s = (self as NSString).substringWithRange(r)
                return Int(CLLocationDegrees(s)!)
            }
            
            initialLat = integers[2]
            initialLon = integers[3]
            finalLat = integers[0]
            finalLon = integers[1]
            
            print("initialLat:", initialLat)
            print("initialLon:", initialLon)
            print("finalLat:", finalLat)
            print("finalLon:", finalLon)
        } catch {
            print("Error parsing combination table bounds string")
        }
        
        
        var count = 1
        var table = XACombinationTable()
        for lat in initialLat ... finalLat {
            for lon in initialLon ... finalLon {
                table.append((count, (lat, lon)))
                count += 1
            }
        }
        
        print("Created combination table of length \(table.count):")
        print(table)
        
        return table
    }
}