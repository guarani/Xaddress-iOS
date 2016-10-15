//
//  Xaddress.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit
import CoreLocation


class XAddressUtils {
    
//    func boundsForPlace(country: XACountry?, state: XAState?, onSuccess: (bounds: Bounds?) -> Void) {
//        var bounds: Bounds?
//        if let abbreviation = state?.shortName {
//            let theState = self.states.rows.filter { aState in
//                let isState1 = aState["stateName1"] == abbreviation
//                let isState2 = aState["stateName2"] == abbreviation
//                let isState3 = aState["stateName3"] == abbreviation
//                return isState1 || isState2 || isState3
//                }.first
//            if let theState = theState, boundsString = theState["bounds"] {
//                bounds = Bounds(bounds: boundsString)
//            }
//        } else if let abbreviation = country?.shortName {
//            let theCountry = self.countries.rows.filter { aCountry in
//                return aCountry["countryCode"] == abbreviation
//                }.first
//            if let theCountry = theCountry, boundsString = theCountry["bounds"] {
//                bounds = Bounds(bounds: boundsString)
//            }
//        }
//        
//        onSuccess(bounds: bounds)
//    }
//    
//    func combinationTable(bounds: Bounds) -> [String] {
//        
//        var table = [String]()
//        
//        let initialLat = Int(bounds.bottomLeftCoordinate!.latitude)
//        let initialLon = Int(bounds.bottomLeftCoordinate!.longitude)
//        
//        let finalLat = Int(bounds.topRightCoordinate!.latitude)
//        let finalLon = Int(bounds.topRightCoordinate!.longitude)
//        
//        var count = 0
//        for lat in initialLat ... finalLat {
//            for lon in initialLon ... finalLon {
//                table.append("\(lat),\(lon)")
//                count += 1
//            }
//        }
//        
//        return table
//    }
//    
//    
//    func xaddressForLocation(location: CLLocationCoordinate2D, combinationTable: [String], onSuccess: (xaddress: Xaddress) -> Void) {
//        let xaddress = Xaddress()
//        
//        let latInt = Int(location.latitude)
//        let lonInt = Int(location.longitude)
//        let firstPart = String(latInt) + "," + String(lonInt)
//        
//        let word2 = combinationTable.enumerate().filter { $0.element == firstPart }.first!.index + 1 // 1 based indexing
//        
//        
//        let latDec = String(String(format: "%.4f", location.latitude).characters.split(".")[1])
//        let lonDec = String(String(format: "%.4f", location.longitude).characters.split(".")[1])
//        
//        let word1 = String(latDec.characters.suffix(2) + lonDec.characters.suffix(2))
//        xaddress.n = Int(String(latDec.characters.prefix(2) + lonDec.characters.prefix(2)))
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            
//            xaddress.word1List = self.words.rows.filter { word in
//                return word["code"]! == word1
//                }.sort {
//                    return $0["popularity"] > $1["popularity"]
//            }
//            xaddress.p1 = xaddress.word1List.first?["word"]
//            
//            xaddress.word2List = self.adjectives.rows.filter { adjective in
//                return adjective["code"]!.hasPrefix(String(word2))
//                }.sort {
//                    return $0["popularity"] > $1["popularity"]
//            }
//            xaddress.p2 = xaddress.word2List.first?["word"]
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                onSuccess(xaddress: xaddress)
//            }
//        }
//    }
}

