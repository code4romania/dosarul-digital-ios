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
    
    func currentUser() -> User? {
        guard let email = AccountManager.shared.email else {
            return nil
        }
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        request.relationshipKeyPathsForPrefetching = ["beneficiaries", "beneficiaries.familyMembers"]
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
        let beneficiariesIds = beneficiaries.map { $0.id }
        
        // delete local beneficiaries who no longer exist on server for the currentUser
        currentUser()?
            .beneficiaries?
            .compactMap { $0 as? Beneficiary }
            .filter { !beneficiariesIds.contains($0.id) }
            .forEach { CoreData.context.delete($0) }
        
        // get all beneficiaries from the database
        let request: NSFetchRequest<Beneficiary> = Beneficiary.fetchRequest()
        guard let allBeneficiaries = CoreData.fetch(request) as? [Beneficiary] else {
            return
        }
        
        // add new beneficiaries
        beneficiaries.forEach { (beneficiary) in
            let beneficiaryEntityDescription = NSEntityDescription.entity(forEntityName: "Beneficiary",
                                                                          in: CoreData.context)
            
            
            
            let localBeneficiary = allBeneficiaries
                .filter({ $0.id == beneficiary.id })
                .first ?? Beneficiary(entity: beneficiaryEntityDescription!,
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
                localForm.formDescription = form.description
                localForm.code = form.code
                localForm.addToBeneficiaries(localBeneficiary)
            })
            
            // remove family members
            localBeneficiary.familyMembers = nil
            
            // add family members
            if let familyMembersIds = beneficiary.familyMembers?.compactMap({ $0.beneficiaryId }),
                familyMembersIds.count > 0 {
                let request: NSFetchRequest<Beneficiary> = Beneficiary.fetchRequest()
                request.predicate = NSPredicate(format: "id in %@", familyMembersIds)
                if let familyMembers = CoreData.fetch(request) as? [Beneficiary] {
                    localBeneficiary.addToFamilyMembers(NSSet(array: familyMembers))
                }
            }
        }
        do {
            try CoreData.save()
        } catch {
            print(error)
        }
        
    }
    
    func assignFormsToBeneficiary(_ beneficiary: Beneficiary, formIds:[Int]) {
        formIds.forEach { (addedFormId) in
            let request: NSFetchRequest<Form> = Form.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", addedFormId)
            guard let forms = CoreData.fetch(request) as? [Form], let form = forms.first else {
                return
            }
            beneficiary.addToForms(form)
        }
    }
    
    func unassignFormsFromBeneficiary(_ beneficiary: Beneficiary, formIds:[Int]) {
        beneficiary
            .forms?
            .compactMap { $0 as? Form }
            .filter { formIds.contains(Int($0.id)) }
            .forEach { CoreData.context.delete($0) }
    }
    
    func currentSectionInfo() -> SectionInfo? {
        guard let stationId = PreferencesManager.shared.section else { return nil }
        return sectionInfo(sectionId: stationId, formId: nil)
    }
    
    func sectionInfo(sectionId: Int, formId: Int?) -> SectionInfo {
        let sectionRequest: NSFetchRequest<SectionInfo> = SectionInfo.fetchRequest()
        sectionRequest.fetchLimit = 1
        sectionRequest.predicate = NSPredicate(format: "sectionId == %d", Int16(sectionId))
        let sections = try? CoreData.context.fetch(sectionRequest)
        if let sectionInfo = sections?.first {
            return sectionInfo
        } else {
            // create it
            let sectionInfoEntityDescription = NSEntityDescription.entity(forEntityName: "SectionInfo", in: CoreData.context)
            let newSectioInfo = SectionInfo(entity: sectionInfoEntityDescription!, insertInto: CoreData.context)
            newSectioInfo.sectionId = Int16(sectionId)
            newSectioInfo.synced = false
            if let formId = formId {
                let formRequest: NSFetchRequest<Form> = Form.fetchRequest()
                formRequest.fetchLimit = 1
                formRequest.predicate = NSPredicate(format: "id == %d", Int16(formId))
                if let form = try? CoreData.context.fetch(formRequest).first {
                    newSectioInfo.form = form
                }
            }
            try? CoreData.context.save()
            return newSectioInfo
        }
    }
    
    func getUnsyncedNotes() -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let syncedPredicate = NSPredicate(format: "synced == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [syncedPredicate])
        let unsyncedNotes = CoreData.fetch(request) as? [Note]
        return unsyncedNotes ?? []
    }
    
    func getUnsyncedQuestions() -> [Question] {
        guard let currentUser = currentUser() else {
            return []
        }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let syncedPredicate = NSPredicate(format: "ANY answers.synced == false AND ANY answers.beneficiary.user == %@", currentUser)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [syncedPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question]
        return unsyncedQuestions ?? []
    }
    
    func getQuestions(forForm formId: Int, formVersion: Int) -> [Question] {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let formPredicate = NSPredicate(format: "formId == %d", formId)
        let formVersionPredicate = NSPredicate(format: "formVersion <= %d", Int16(formVersion))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [formPredicate, formVersionPredicate])
        let matchedQuestions = CoreData.fetch(request) as? [Question]
        return matchedQuestions ?? []
    }
    
    func delete(questions: [Question]) {
        let count = questions.count
        for question in questions {
            if let answers = question.answers,
                let all = answers.allObjects as? [Answer] {
                for answer in all {
                    if let notes = answer.beneficiary?.notes?.allObjects as? [Note] {
                        for note in notes {
                            CoreData.context.delete(note)
                        }
                    }
                    CoreData.context.delete(answer)
                }
            }
            CoreData.context.delete(question)
            question.sectionInfo?.removeFromQuestions(question)
        }
        DebugLog("Deleted \(count) questions")
        try? CoreData.save()
    }
    
    func getQuestion(withId id: Int) -> Question? {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let idPredicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        request.predicate = idPredicate
        let matches = CoreData.fetch(request) as? [Question]
        return matches?.first
    }
    
    func getAnsweredQuestions(inFormWithId formId: Int, beneficiary: Beneficiary) -> [Question] {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let formPredicate = NSPredicate(format: "formId == %d", formId)
        let beneficiaryPredicate = NSPredicate(format: "ANY answers.beneficiary == %@", beneficiary)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [formPredicate,
                                                                                beneficiaryPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question]
        return unsyncedQuestions ?? []
    }
    
    func getAnswers(inFormWithId formId: Int, beneficiary: Beneficiary) -> [Answer] {
        guard let answers = beneficiary.answers?.allObjects as? [Answer] else {
            return []
        }
        var result = [Answer]()
        for answer in answers {
            guard let storedFormId = answer.question?.sectionInfo?.form?.id,
                Int(storedFormId) == formId else {
                    continue
            }
            result.append(answer)
        }
        return result
    }
    
    func setQuestionsSynced(withIds ids: [Int16]) {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let formPredicate = NSPredicate(format: "id IN %@", ids)
        request.predicate = formPredicate
        let unsyncedQuestions = CoreData.fetch(request) as? [Question] ?? []
        let unsyncedAnswers = unsyncedQuestions.compactMap({ $0.answers?.allObjects as? [Answer] }).flatMap({ $0 })
        for answer in unsyncedAnswers {
            answer.synced = true
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
    func getNotes(for beneficiary: Beneficiary?, attachedToQuestion questionId: Int?) -> [Note] {
        guard let notes = beneficiary?.notes?.allObjects as? [Note] else {
            return []
        }
        return notes
            .filter({ $0.questionID == questionId ?? -1 })
            .sorted(by: {
                guard let firstDate = $0.date, let secondDate = $1.date else {
                    return true
                }
                return firstDate.compare(secondDate) == .orderedDescending
            })
    }
    
    func saveNote(withText text: String, fileAttachment: Data?, questionId: Int?) throws -> Note {
        let noteEntityDescription = NSEntityDescription.entity(forEntityName: "Note", in: CoreData.context)
        let note = Note(entity: noteEntityDescription!, insertInto: CoreData.context)
        note.beneficiary = ApplicationData.shared.beneficiary
        note.body = text
        note.date = Date()
        note.questionID = Int16(questionId ?? -1)
        note.file = fileAttachment
        note.synced = false
        note.sectionInfo = currentSectionInfo()
        try CoreData.save()
        return note
    }
    
}
