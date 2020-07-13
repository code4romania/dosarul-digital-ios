//
//  DB.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation
import CoreData

class DB: NSObject {
    static let shared = DB()

    private var _currentUser: User?
    
    func currentUser() -> User? {
        guard _currentUser == nil else {
            return _currentUser
        }
        guard let email = AccountManager.shared.email else {
            return nil
        }
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        request.relationshipKeyPathsForPrefetching = ["beneficiaries", "beneficiaries.revisions"]
        request.fetchLimit = 1
        let matches = CoreData.fetch(request) as? [User]
        return matches?.first
    }
    
    var needsSync: Bool {
        return getUnsyncedNotes().count + getUnsyncedQuestions().count > 0
    }
    
    func saveUser(_ account: AccountManagerType, persistent: Bool) {
        let userEntityDescription = NSEntityDescription.entity(forEntityName: "User", in: CoreData.context)
        let user = User(entity: userEntityDescription!, insertInto: CoreData.context)
        user.email = account.email
        user.expiresIn = Int64(account.expiresIn ?? -1)
        user.accessToken = account.accessToken
        if (persistent) {
            do {
                try CoreData.save()
            } catch {
                print(error)
            }
        }
    }
    
    func createBeneficiary(persistent: Bool) -> Beneficiary {
        let beneficiaryEntityDescription = NSEntityDescription.entity(forEntityName: "Beneficiary", in: CoreData.context)
        let beneficiary = Beneficiary(entity: beneficiaryEntityDescription!, insertInto: CoreData.context)
        if (persistent) {
            do {
                try CoreData.save()
            } catch {
                print(error)
            }
        }
        return beneficiary
    }
    
    func saveBeneficiaries(_ beneficiaries: [BeneficiaryDetailedResponse]) {
        #warning("local beneficiaries are fully overwritten with the server values, even if some of their properties have been modified")
        let beneficiariesIds = beneficiaries.map { $0.id }
        
        // delete local beneficiaries who no longer exist on server for the currentUser
        currentUser()?
            .beneficiaries?
            .compactMap { $0 as? Beneficiary }
            .filter { !beneficiariesIds.contains($0.id) }
            .forEach { CoreData.context.delete($0) }
        
        // add new beneficiaries
        beneficiaries.forEach { (beneficiary) in
            let beneficiaryEntityDescription = NSEntityDescription.entity(forEntityName: "Beneficiary",
                                                                          in: CoreData.context)
            
            let localBeneficiary = currentUser()?
                .beneficiaries?
                .compactMap({ $0 as? Beneficiary })
                .filter({ $0.id == beneficiary.id }).first ?? Beneficiary(entity: beneficiaryEntityDescription!,
                                                                           insertInto: CoreData.context)
            localBeneficiary.user = currentUser()
            localBeneficiary.age = beneficiary.age
            localBeneficiary.birthDate = beneficiary.birthDate
            localBeneficiary.civilStatus = beneficiary.civilStatus
            localBeneficiary.county = beneficiary.county
            localBeneficiary.countyId = beneficiary.countyId
            localBeneficiary.city = beneficiary.city
            localBeneficiary.cityId = beneficiary.cityId
            localBeneficiary.gender = beneficiary.gender
            localBeneficiary.id = beneficiary.id
            localBeneficiary.name = beneficiary.name
            localBeneficiary.userId = beneficiary.userId
            
            // remove deallocated forms
            let localForms = localBeneficiary.forms?.compactMap({ $0 as? Form })
            localForms?
                .filter { !(beneficiary.forms ?? [])
                    .map {$0.id}
                    .contains($0.id)
            }
            .forEach { CoreData.context.delete($0) }
            
            beneficiary.forms?.forEach({ (form) in
                // add new forms / update existing
                let formEntityDescription = NSEntityDescription.entity(forEntityName: "Form",
                                                                       in: CoreData.context)
                let localForm = localForms?.filter({ $0.id == form.id }).first ?? Form(entity: formEntityDescription!,
                                                                                       insertInto: CoreData.context)
                localForm.id = form.id
                localForm.addToBeneficiaries(localBeneficiary)
            })
            
        }
        do {
            try CoreData.save()
        } catch {
            print(error)
        }
        
    }
    
    func assignFormsToBeneficiary(_ beneficiary: Beneficiary, formIds:[Int]) {
        formIds.forEach { (addedFormId) in
            let formEntityDescription = NSEntityDescription.entity(forEntityName: "Form", in: CoreData.context)
            let form = Form(entity: formEntityDescription!, insertInto: CoreData.context)
            form.id = Int16(addedFormId)
            beneficiary.addToForms(form)
        }
    }
    
    func unassignFormsFromBeneficiary(_ beneficiary: Beneficiary, formIds:[Int]) {
        beneficiary
            .forms?
            .compactMap {$0 as? Form }
            .filter { formIds.contains(Int($0.id)) }
            .forEach { CoreData.context.delete($0) }
    }
    
    func currentSectionInfo() -> SectionInfo? {
        guard let stationId = PreferencesManager.shared.section else { return nil }
        return sectionInfo(sectionId: stationId)
    }
    
    func sectionInfo(sectionId: Int) -> SectionInfo {
        let request: NSFetchRequest<SectionInfo> = SectionInfo.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "sectionId == %d", Int16(sectionId))
        let sections = try? CoreData.context.fetch(request)
        if let sectionInfo = sections?.first {
            return sectionInfo
        } else {
            // create it
            let sectionInfoEntityDescription = NSEntityDescription.entity(forEntityName: "SectionInfo", in: CoreData.context)
            let newSectioInfo = SectionInfo(entity: sectionInfoEntityDescription!, insertInto: CoreData.context)
            newSectioInfo.sectionId = Int16(sectionId)
            newSectioInfo.synced = false
            try! CoreData.context.save()
            return newSectioInfo
        }
    }
    
    func getUnsyncedNotes() -> [Note] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let syncedPredicate = NSPredicate(format: "synced == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, syncedPredicate])
        let unsyncedNotes = CoreData.fetch(request) as? [Note]
        return unsyncedNotes ?? []
    }
    
    func getUnsyncedQuestions() -> [Question] {
        guard let currentUser = currentUser() else {
            return []
        }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        #warning("also add predicate only for current user")
        let syncedPredicate = NSPredicate(format: "synced == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [syncedPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question]
        return unsyncedQuestions ?? []
    }
    
    func getQuestions(forForm formCode: String, formVersion: Int) -> [Question] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let formPredicate = NSPredicate(format: "form == %@", formCode)
        let formVersionPredicate = NSPredicate(format: "formVersion <= %d", Int16(formVersion))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, formPredicate, formVersionPredicate])
        let matchedQuestions = CoreData.fetch(request) as? [Question]
        return matchedQuestions ?? []
    }
    
    func delete(questions: [Question]) {
        let count = questions.count
        for question in questions {
            if let answers = question.answers,
                let all = answers.allObjects as? [Answer] {
                for answer in all {
                    CoreData.context.delete(answer)
                }
            }
            let notes = getNotes(attachedToQuestion: Int(question.id))
            for note in notes {
                CoreData.context.delete(note)
            }
            CoreData.context.delete(question)
            question.sectionInfo?.removeFromQuestions(question)
        }
        DebugLog("Deleted \(count) questions")
        try? CoreData.save()
    }
    
    func getQuestion(withId id: Int) -> Question? {
        guard let section = currentSectionInfo() else { return nil }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let idPredicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, idPredicate])
        let matches = CoreData.fetch(request) as? [Question]
        return matches?.first
    }
    
    func getAnsweredQuestions(inFormWithCode formCode: String) -> [Question] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let formPredicate = NSPredicate(format: "form == %@", formCode)
        let answeredPredicate = NSPredicate(format: "answered == true")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, formPredicate, answeredPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question]
        return unsyncedQuestions ?? []
    }
    
    func setQuestionsSynced(withIds ids: [Int16]) {
        guard let section = currentSectionInfo() else { return }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let formPredicate = NSPredicate(format: "id IN %@", ids)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, formPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question] ?? []
        for question in unsyncedQuestions {
            question.synced = true
        }
        
        do {
            try CoreData.save()
        } catch {
            DebugLog("Error: couldn't save synced status locally: \(error)")
        }
    }

    /// Returns the list of all saved notes in this section. Optionally you can pass the questionId to return
    /// only the notes attached to that question. If nil, it will return all notes that aren't attached to any question
    /// - Parameter questionId: the question id
    func getNotes(attachedToQuestion questionId: Int?) -> [Note] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let questionPredicate = NSPredicate(format: "questionID == %d", Int16(questionId ?? -1))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, questionPredicate])
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let notes = CoreData.fetch(request) as? [Note]
        return notes ?? []
    }
    
    func saveNote(withText text: String, fileAttachment: Data?, questionId: Int?) throws -> Note {
        let noteEntityDescription = NSEntityDescription.entity(forEntityName: "Note", in: CoreData.context)
        let note = Note(entity: noteEntityDescription!, insertInto: CoreData.context)
        note.body = text
        note.date = Date()
        note.questionID = Int16(questionId ?? -1)
        note.file = fileAttachment as NSData?
        note.synced = false
        note.sectionInfo = currentSectionInfo()
        try CoreData.save()
        return note
    }
    
}

/*
extension DB {
    func udpateBeneficiary(_ beneficiary: inout Beneficiary, with response: BeneficiaryResponse) {
        beneficiary.userId = response.userId ?? beneficiary.userId
        beneficiary.id = response.id
        beneficiary.name = response.name
        beneficiary.civilStatus = response.civilStatus
        beneficiary.birthDate = response.birthDate
        beneficiary.age = response.age ?? beneficiary.age
        beneficiary.county = response.county ?? beneficiary.county
        beneficiary.countyId = response.countyId ?? beneficiary.countyId
        beneficiary.cityId = response.cityId ?? beneficiary.cityId
        beneficiary.gender = response.gender ?? beneficiary.gender
        #warning("process family members and forms")
        /**
 var userId: Int16?                      // received on /api/v1/beneficiary/{id}
        var id: Int16                           // always received
        var name: String                        // always received
        var civilStatus: Int16                  // always received
        var birthDate: Date?                    // received on /api/v1/beneficiary/{id}
        var age: Int16?                         // received on /api/v1/beneficiary
        var county: String?                     // received on /api/v1/beneficiary
        var city: String?                       // received on /api/v1/beneficiary
        var countyId: Int16?                    // received on /api/v1/beneficiary/{id}
        var cityId: Int16?                      // received on /api/v1/beneficiary/{id}
        var gender: Int16?                      // always received
        var familyMembers: [Int16]?             // received on /api/v1/beneficiary/{id}
        var forms: [FormBeneficiaryResponse]?   // received on /api/v1/beneficiary/{id}
 */
    }
    
    func beneficiaryRequest(from beneficiary: Beneficiary) -> BeneficiaryRequest {
        let beneficiaryRequest = BeneficiaryRequest(id: Int(beneficiary.id),
                                                    userId: Int(beneficiary.userId),
                                                    name: beneficiary.name,
                                                    birthDate: beneficiary.birthDate,
                                                    civilStatus: CivilStatus(rawValue: Int(beneficiary.civilStatus))!,
                                                    cityId: Int(beneficiary.cityId),
                                                    countyId: Int(beneficiary.countyId),
                                                    gender: Gender(Int(beneficiary.gender)),
                                                    formIds: formsArray.compactMap({
                                                        ($0 as? FormSetCellModel)?.id
                                                    }),
                                                    newAllocatedFormsIds: nil,
                                                    dealocatedFormsIds: nil)
        beneficiary.birthDate = model.birthDate
        beneficiary.cityId = Int(model.cityId)
        beneficiary.countyId = Int(model.countyId)
        beneficiary.id = Int(model.id)
        beneficiary.name = model.name
        beneficiary.userId = Int(model.userId)
        if let civilStatus = CivilStatus(rawValue: Int(model.civilStatus)) {
            beneficiary.civilStatus = civilStatus
        }
        if let gender = Gender(rawValue: Int(model.gender)) {
            beneficiary.gender = gender
        }
    }
}
*/
