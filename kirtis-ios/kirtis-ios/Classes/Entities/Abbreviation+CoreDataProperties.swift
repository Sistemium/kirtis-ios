//
//  Abbreviation+CoreDataProperties.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 09/12/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Abbreviation {

    @NSManaged var shortForm: String?
    @NSManaged var longForm: String?
    @NSManaged var group: GroupOfAbbreviations?

}
