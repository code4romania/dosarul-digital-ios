//
//  Revision+CoreDataProperties.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 02/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//
//

import Foundation
import CoreData


extension Revision {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Revision> {
        return NSFetchRequest<Revision>(entityName: "Revision")
    }

    @NSManaged public var propertyName: String?
    @NSManaged public var modified: Bool
    @NSManaged public var beneficiaries: NSSet?

}

// MARK: Generated accessors for beneficiaries
extension Revision {

    @objc(addBeneficiariesObject:)
    @NSManaged public func addToBeneficiaries(_ value: Beneficiary)

    @objc(removeBeneficiariesObject:)
    @NSManaged public func removeFromBeneficiaries(_ value: Beneficiary)

    @objc(addBeneficiaries:)
    @NSManaged public func addToBeneficiaries(_ values: NSSet)

    @objc(removeBeneficiaries:)
    @NSManaged public func removeFromBeneficiaries(_ values: NSSet)

}
