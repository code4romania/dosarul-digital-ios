//
//  User+CoreDataProperties.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 26/05/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import Foundation
import CoreData

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var email: String?
    @NSManaged public var id: Int16

}
