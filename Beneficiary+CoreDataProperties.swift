//
//  Beneficiary+CoreDataProperties.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 02/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//
//

import Foundation
import CoreData


extension Beneficiary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Beneficiary> {
        return NSFetchRequest<Beneficiary>(entityName: "Beneficiary")
    }

    @NSManaged public var age: Int16
    @NSManaged public var birthDate: Date?
    @NSManaged public var city: String?
    @NSManaged public var cityId: Int16
    @NSManaged public var civilStatus: Int16
    @NSManaged public var county: String?
    @NSManaged public var countyId: Int16
    @NSManaged public var gender: Int16
    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var user: User?
    @NSManaged public var userId: Int16
    @NSManaged public var revisions: NSSet?

}

// MARK: Generated accessors for revisions
extension Beneficiary {

    @objc(addRevisionsObject:)
    @NSManaged public func addToRevisions(_ value: Revision)

    @objc(removeRevisionsObject:)
    @NSManaged public func removeFromRevisions(_ value: Revision)

    @objc(addRevisions:)
    @NSManaged public func addToRevisions(_ values: NSSet)

    @objc(removeRevisions:)
    @NSManaged public func removeFromRevisions(_ values: NSSet)

}
