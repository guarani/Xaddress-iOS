//
//  XAState+CoreDataProperties.swift
//  
//
//  Created by Paul Von Schrottky on 10/15/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension XAState {

    @NSManaged var totalCombinations: NSNumber?
    @NSManaged var name2: String?
    @NSManaged var name1: String?
    @NSManaged var lon: NSNumber?
    @NSManaged var lat: NSNumber?
    @NSManaged var code: String?
    @NSManaged var bounds: String?
    @NSManaged var countryCode: String?
    @NSManaged var name3: String?
    @NSManaged var googleName: String?
    @NSManaged var googleAdmin: String?
    @NSManaged var countryName: String?

}
