//
//  Adjective+CoreDataProperties.swift
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

extension Adjective {

    @NSManaged var code: String?
    @NSManaged var kind: String?
    @NSManaged var popularity: NSNumber?
    @NSManaged var word: String?

}
