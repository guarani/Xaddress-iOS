//
//  XAState.swift
//  
//
//  Created by Paul Von Schrottky on 10/15/16.
//
//

import Foundation
import CoreData
import SwiftyJSON


class XAState: NSManagedObject {
    
    class func matchingGooglePlace(googlePlace: JSON, inManagedContext moc: NSManagedObjectContext) -> XAState? {
        guard let result = googlePlace["results"].array?.first else { return nil }
        
        if let addressComponents = result["address_components"].array {
            let stateInfo = addressComponents.filter { component in
                let isState = component["types"].array?.filter { type in
                    type == "administrative_area_level_1"
                }.count > 0
                return isState
            }.first
            guard let name = stateInfo?["long_name"].string else { return nil }
            
            let fetchRequest = NSFetchRequest(entityName: "XAState")
            fetchRequest.predicate = NSPredicate(format: "name1 == %@ OR name2 == %@ OR name3 == %@", name, name, name)
            let states = try! moc.executeFetchRequest(fetchRequest) as! [XAState]
            return states.first
        }
        return nil
    }

}
