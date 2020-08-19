//
//  Note+CoreDataProperties.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 29/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var body: String?
    @NSManaged public var date: Date?
    @NSManaged public var file: Data?
    @NSManaged public var questionID: Int16
    @NSManaged public var synced: Bool
    @NSManaged public var sectionInfo: SectionInfo?
    @NSManaged public var beneficiary: Beneficiary?

}
