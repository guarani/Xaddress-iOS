//
//  XACountry.swift
//  
//
//  Created by Paul Von Schrottky on 10/15/16.
//
//

import Foundation
import CoreData
import SwiftyJSON


class XACountry: NSManagedObject {
    
    class func matchingGooglePlace(googlePlace: JSON, inManagedContext moc: NSManagedObjectContext) -> XACountry? {
        guard let result = googlePlace["results"].array?.first else { return nil }
        
        if let addressComponents = result["address_components"].array {
            let countryInfo = addressComponents.filter { component in
                let isCountry = component["types"].array?.filter { type in
                    type == "country"
                }.count > 0
                return isCountry
            }.first
            guard let name = countryInfo?["long_name"].string else { return nil }
            
            let fetchRequest = NSFetchRequest(entityName: "XACountry")
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            let countries = try! moc.executeFetchRequest(fetchRequest) as! [XACountry]
            return countries.first
        }
        return nil
    }
}
