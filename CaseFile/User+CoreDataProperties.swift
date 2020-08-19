//
//  User+CoreDataProperties.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 02/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var accessToken: String?
    @NSManaged public var expiresIn: Int64
    @NSManaged public var beneficiaries: NSSet?

}

// MARK: Generated accessors for beneficiaries
extension User {

    @objc(addBeneficiariesObject:)
    @NSManaged public func addToBeneficiaries(_ value: Beneficiary)

    @objc(removeBeneficiariesObject:)
    @NSManaged public func removeFromBeneficiaries(_ value: Beneficiary)

    @objc(addBeneficiaries:)
    @NSManaged public func addToBeneficiaries(_ values: NSSet)

    @objc(removeBeneficiaries:)
    @NSManaged public func removeFromBeneficiaries(_ values: NSSet)

}
