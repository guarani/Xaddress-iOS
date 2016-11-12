//
//  XANoun.swift
//  
//
//  Created by Paul Von Schrottky on 10/15/16.
//
//

import Foundation
import CoreData


class XANoun: NSManagedObject {

    class func matchingCode(code: String, inManagedContext moc: NSManagedObjectContext) -> [XANoun]? {
        
        let fetchRequest = NSFetchRequest(entityName: "XANoun")
        fetchRequest.predicate = NSPredicate(format: "code == %@", code)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "popularity", ascending: false) ]
        let nouns = try! moc.executeFetchRequest(fetchRequest) as! [XANoun]
        return nouns
    }

}
