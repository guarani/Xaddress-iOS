//
//  XAImage+CoreDataProperties.swift
//  XaddressLoader
//
//  Created by Paul Von Schrottky on 11/12/16.
//  Copyright © 2016 Xaddress. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension XAImage {

    @NSManaged var es: String?
    @NSManaged var index: NSNumber?
    @NSManaged var en: String?

}
