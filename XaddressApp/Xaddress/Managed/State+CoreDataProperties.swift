//
//  State+CoreDataProperties.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension State {

    @NSManaged var bounds: String?
    @NSManaged var code: String?
    @NSManaged var countryCode: String?
    @NSManaged var countryName: String?
    @NSManaged var googleAdmin: String?
    @NSManaged var googleName: String?
    @NSManaged var lat: NSNumber?
    @NSManaged var lon: NSNumber?
    @NSManaged var name1: String?
    @NSManaged var name2: String?
    @NSManaged var name3: String?
    @NSManaged var totalCombinations: NSNumber?

}
