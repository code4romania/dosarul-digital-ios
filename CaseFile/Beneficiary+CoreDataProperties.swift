//
//  Beneficiary+CoreDataProperties.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 29/07/2020.
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
    @NSManaged public var userId: Int16
    @NSManaged public var answers: NSSet?
    @NSManaged public var familyMembers: NSSet?
    @NSManaged public var forms: NSSet?
    @NSManaged public var revisions: NSSet?
    @NSManaged public var user: User?
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for answers
extension Beneficiary {

    @objc(addAnswersObject:)
    @NSManaged public func addToAnswers(_ value: Answer)

    @objc(removeAnswersObject:)
    @NSManaged public func removeFromAnswers(_ value: Answer)

    @objc(addAnswers:)
    @NSManaged public func addToAnswers(_ values: NSSet)

    @objc(removeAnswers:)
    @NSManaged public func removeFromAnswers(_ values: NSSet)

}

// MARK: Generated accessors for familyMembers
extension Beneficiary {

    @objc(addFamilyMembersObject:)
    @NSManaged public func addToFamilyMembers(_ value: Beneficiary)

    @objc(removeFamilyMembersObject:)
    @NSManaged public func removeFromFamilyMembers(_ value: Beneficiary)

    @objc(addFamilyMembers:)
    @NSManaged public func addToFamilyMembers(_ values: NSSet)

    @objc(removeFamilyMembers:)
    @NSManaged public func removeFromFamilyMembers(_ values: NSSet)

}

// MARK: Generated accessors for forms
extension Beneficiary {

    @objc(addFormsObject:)
    @NSManaged public func addToForms(_ value: Form)

    @objc(removeFormsObject:)
    @NSManaged public func removeFromForms(_ value: Form)

    @objc(addForms:)
    @NSManaged public func addToForms(_ values: NSSet)

    @objc(removeForms:)
    @NSManaged public func removeFromForms(_ values: NSSet)

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

// MARK: Generated accessors for notes
extension Beneficiary {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}
