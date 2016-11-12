//
//  XAAdjective.swift
//  
//
//  Created by Paul Von Schrottky on 10/15/16.
//
//

import Foundation
import CoreData


class XAAdjective: NSManagedObject {

    class func matchingCode(code: String, inManagedContext moc: NSManagedObjectContext) -> [XAAdjective]? {
        let fetchRequest = NSFetchRequest(entityName: "XAAdjective")
        fetchRequest.predicate = NSPredicate(format: "code BEGINSWITH %@", code)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "popularity", ascending: false) ]
        let adjectives = try! moc.executeFetchRequest(fetchRequest) as! [XAAdjective]
        return adjectives
    }

}
