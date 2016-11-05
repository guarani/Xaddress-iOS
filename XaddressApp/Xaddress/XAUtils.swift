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


class XAUtils {
    class func xaddressForText(text: String, country: XACountry, state: XAState?) -> CLLocationCoordinate2D? {
        
        var lat0: String!
        var lat1: String!
        var lat2: String!
        var lon0: String!
        var lon1: String!
        var lon2: String!
        
        
        var boundsString = country.bounds!
        var combinations = country.totalCombinations!.integerValue
        if let stateCombinations = state?.totalCombinations?.integerValue {
            combinations = stateCombinations
            boundsString = state!.bounds!
        }
        
        guard let components = xa_addressComponentsText(text, combinations: combinations), word1 = components.word1 else {
            print("Error: Failed to extract components from xaddress")
            return nil
        }
        
        let word1Code = XAUtils.codeFromWord(word1)
        
        if combinations > 0 {
            let word2Code = XAUtils.codeFromWord(components.word2!)
            
            let combinationTable = XAUtils.combinationTableForBoundsString(boundsString)
            let len = String(combinationTable.count).characters.count
            
            let word2CodeLookup = Int(word2Code.substringToIndex(word2Code.startIndex.advancedBy(len)))!
            
            let latLon = combinationTable[word2CodeLookup - 1]
            
            lat0 = String(latLon.1.lat)
            lat1 = String(String(components.number!).characters.prefix(2))
            lat2 = String(word1Code.characters.prefix(2))
            
            lon0 = String(latLon.1.lon)
            lon1 = String(String(components.number!).characters.suffix(2))
            lon2 = String(word1Code.characters.suffix(2))
            
        } else {
            
//            lat0 = CLLocationDegrees(boundsString.substringToIndex(boundsString.rangeOfString(".")!.startIndex))
//            lat1 = CLLocationDegrees(String(components.number!).substringToIndex(String(components.number!).startIndex.advancedBy(2)))
//            lat2 = CLLocationDegrees(word1.substringToIndex(word1.startIndex.advancedBy(2)))
//            
//            lon0 = CLLocationDegrees(latLon.1.lon)
//            lon1 = CLLocationDegrees(String(components.number!).substringFromIndex(String(components.number!).startIndex.advancedBy(2)))
//            lon2 = CLLocationDegrees(word1.substringFromIndex(word1.startIndex.advancedBy(2)))
        }
        
        let location = String(lat0) + "." + String(lat1) + String(lat2) + "," + String(lon0) + "." + String(lon1) + String(lon2)
        print(location)
        let comps = location.characters.split(",")
        let lat = String(comps[0])
        let lon = String(comps[1])
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat)!, longitude: CLLocationDegrees(lon)!)
    }

    
    class func xa_addressComponentsText(text: String, combinations: Int) -> XAAddressComponents? {
        
        let str = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) as NSString
        guard str.length > 0 else { return nil }
        
        let addressComponents = XAAddressComponents()
        
        do {
            let regex = try NSRegularExpression(pattern: "(\\w*)\\s*(\\w*)\\s*(\\w*)", options: NSRegularExpressionOptions(rawValue: 0))
            
            let all = NSRange(location: 0, length: text.characters.count)
            var groups = [String]()
            if let result = regex.matchesInString(text, options: NSMatchingOptions(rawValue: 0), range: all).first {
                
                for i in 1 ..< result.numberOfRanges {
                    let r = result.rangeAtIndex(i)
                    let s = str.substringWithRange(r)
                    groups.append(s)
                }
            }
            
            let numberElements = groups.filter {
                return Int($0) != nil && $0.characters.count == 4
            }
            guard numberElements.count == 1 else {
                print("Error: An xaddress must contain exactly one four-digit number.")
                return nil
            }
            
            if combinations == 0 && groups.count > 2 {
                print("Error: An xaddress with zero combinations must have only one word.")
                return nil
            }
            
            if combinations > 0 && groups.count < 3 {
                print("Error: An xaddress with one or more combinations must have two words. ")
                return nil
            }
            
            if let number = Int(groups[0]) {
                addressComponents.number = number
                if groups.count == 3 {
                    addressComponents.word1 = groups[2]
                    addressComponents.word2 = groups[1]
                } else {
                    addressComponents.word1 = groups[1]
                }
            } else  {
                if groups.count == 3 {
                    addressComponents.word1 = groups[0]
                    addressComponents.word2 = groups[1]
                    addressComponents.number = Int(groups[2])!
                } else {
                    addressComponents.word1 = groups[0]
                    addressComponents.number = Int(groups[1])!
                }
            }
            
            print(addressComponents)
            return addressComponents
        } catch {
            print("Error parsing xaddress string with regex.")
        }
        
        return nil
    }
    
    class func codeFromWord(word: String) -> String {
        
        // Convert to an array of double ASCII values.
        // e.g. for "PEARL", the result is:
        let nums: [CLLocationDegrees] = word.characters.map {
            let characterString = String($0)
            let scalars = characterString.unicodeScalars
            return CLLocationDegrees(scalars[scalars.startIndex].value)
        }
        
        // Calculate the result by alternatively multiplying/dividing the values.
        // e.g. for [80.0, 69.0, 65.0, 82.0, 76.0] the operations are equal to: 80/68*65/82*76 = 69.848002831
        let res = nums.enumerate().reduce(1) {
            $1.index % 2 == 0 ? $0 * $1.element : $0 / $1.element
        }
        
        // Get final value (first 4 digits after decimal place).
        // e.g. for 69.848002831 the result is 8480
        // TODO: Swift rounds 90.2584550539029 to 2585, is this correct?
        let str = String(res)
        let startIndex = str.rangeOfString(".")!.startIndex.advancedBy(1)
        let endIndex = startIndex.advancedBy(4)
        let code = str.substringWithRange(startIndex..<endIndex)
        return code
    }
    
    class func combinationTableForBoundsString(boundsString: String) -> XACombinationTable {
        
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
            let range = NSRange(location: 0, length: boundsString.characters.count)
            
            // e.g. -8, 125, -1, 134
            let integers: [Int] = regex.matchesInString(boundsString, options: options, range: range).map { result in
                let r = result.rangeAtIndex(0)
                let s = (boundsString as NSString).substringWithRange(r)
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