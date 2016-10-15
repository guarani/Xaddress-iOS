//
//  Constant.swift
//  FuelFinder
//
//  Created by Paul Von Schrottky on 8/13/16.
//  Copyright © 2016 Paul Von Schrottky. All rights reserved.
//

import UIKit

typealias FFDictionary = Dictionary<String, AnyObject?>
typealias FFArray = Array<FFDictionary>


struct Constant {
    struct Color {
        static let Principal = UIColor(red: 243/255.0, green: 241/255.0, blue: 237/255.0, alpha: 1)
        static let Secondary = UIColor(red: 221/255.0, green: 75/255.0, blue: 57/255.0, alpha: 1)
        static let Light = UIColor.whiteColor()
        static let TextLight = UIColor.whiteColor()
        static let TextDark = UIColor.blackColor()
        static let Red = UIColor(red: 178/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1)
        static let Foreground = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        static let Background = UIColor.whiteColor()
        static let Border = UIColor.whiteColor()
    }
    
    struct Config {
//#if DEBUG
        static let BaseURL = "http://localhost:8080"
//#else
//        static let BaseURL = "https://fuelfindergo.appspot.com"
//#endif
        static let MapDefaultZoom: Float = 15
        static let GasStationSearchRadius: Float = 3000
        static let DefaultLocationLat: Double = -25.260517
        static let DefaultLocationLon: Double = -57.5277696
        static let MinLocationAccuracy: Double = 50
        
        static let MaxLiters: Int = 999
        static let MaxTotal: Int = 999999
    }


}
