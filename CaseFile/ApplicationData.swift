//
//  ApplicationData.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 26/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class ApplicationData: NSObject {
    static let shared = ApplicationData()
        
    enum Keys {
        case patient
        case patientForms
        case patientAddedForms
        case patientRemovedForms
        case patientFormCompletionDate
        case patientFamilyMember
        case hud(view: UIView)
        
        var value: String {
            switch self {
            case .patient:
                return "ObjectPatient"
            case .patientForms:
                return "ObjectPatientForms"
            case .patientAddedForms:
                return "ObjectPatientFormsAdded"
            case .patientRemovedForms:
                return "ObjectPatientFormsRemoved"
            case .patientFormCompletionDate:
                return "ObjectPatientFormCompletionDate"
                case .patientFamilyMember:
                    return "ObjectPatientFamilyMember"
            case .hud(let view):
                return String(format: "%p", unsafeBitCast(view, to: Int.self))
            }
        }
    }
    
    /// Check this property for existing frequently used data in memory. The NSObject is always an array to infer Any, AnyObject and NSObject.
    /// Whoever stores the object is responsible for removing it.
    private(set) var objectRepository = NSMapTable<NSString, NSObject>.strongToStrongObjects()
    
    func object(for type: Keys) -> NSObject? {
        return objectRepository.object(forKey: NSString(string: type.value))
    }
    
    func setObject(_ object: NSObject, for type: Keys) {
        objectRepository.setObject(object, forKey: NSString(string: type.value))
        DebugLog("Setting object of type \(type) resulted in \(objectRepository)")
    }
    
    func removeObject(for type: Keys) {
        objectRepository.removeObject(forKey: NSString(string: type.value))
        DebugLog("Removing object of type \(type) resulted in \(objectRepository)")
    }
    
    var beneficiary: Beneficiary? {
        guard let currentBeneficiaryArray = ApplicationData.shared.object(for: .patient) as? NSArray,
            let currentBeneficiary = currentBeneficiaryArray[0] as? Beneficiary else {
            return nil
        }
        return currentBeneficiary
    }
    
    var beneficiaryFamilyMember: Beneficiary? {
        guard let currentFamilyMemberArray = ApplicationData.shared.object(for: .patientFamilyMember) as? NSArray,
            let familyMember = currentFamilyMemberArray[0] as? Beneficiary else {
            return nil
        }
        return familyMember
    }
    
    var completionDate: Date? {
        guard let completionDateArray = ApplicationData.shared.object(for: .patientFormCompletionDate) as? NSArray,
            let date = completionDateArray[0] as? Date else {
            return nil
        }
        return date
    }
    
    private override init() {
        super.init()
    }
    
    func downloadUpdatedBeneficiaries(then callback: ((Error?) -> Void)?) {
        AppDelegate.dataSourceManager.fetchBeneficiaries { (beneficiaries, error) in
            guard error == nil else {
                callback?(error)
                return
            }
            guard let beneficiaries = beneficiaries else {
                callback?(APIError.incorrectFormat(reason: "Error.IncorrectFormat"))
                return
            }
            DB.shared.saveBeneficiaries(beneficiaries)
        }
    }
    
    func downloadUpdatedForms(then callback: @escaping (Error?) -> Void) {
        DebugLog("Downloading new form summaries")
        
        AppDelegate.dataSourceManager.fetchForms() { (forms, error) in
            if let error = error {
                callback(error)
            } else {
                self.downloadUpdatedFormsInSet(forms ?? []) {
                    // store the new summaries
                    LocalStorage.shared.forms = forms
                    callback(nil)
                }
            }
        }
    }
    
    fileprivate func downloadUpdatedFormsInSet(_ forms: [FormResponse], then callback: @escaping () -> Void) {
        let api = AppDelegate.dataSourceManager
        let existingForms = LocalStorage.shared.forms ?? []
        let indexedExistingForms = existingForms.reduce(into: [Int: FormResponse]()) { $0[$1.id] = $1 }
        let newForms = forms
        var formsThatNeedUpdates: [FormResponse] = []
        for form in newForms {
            if let existing = indexedExistingForms[form.id],
                existing.version >= form.version {
                continue
            }
            formsThatNeedUpdates.append(form)
        }
        
        guard formsThatNeedUpdates.count > 0 else {
            // no updates necessary
            DebugLog("No new forms")
            callback()
            return
        }
        
        DebugLog("Downloading \(formsThatNeedUpdates.count) new forms")
        var updatedFormCount = 0
        for form in formsThatNeedUpdates {
            
            // delete any questions, answers, notes that were answered to the old form
            if let existing = indexedExistingForms[form.id] {
                deleteUserData(forForm: form.id, formVersion: existing.version)
            }
            
            api.fetchForm(formId: form.id) { (formSections, error) in
                updatedFormCount += 1
                if let sections = formSections, sections.count > 0 {
                    // store this
                    DebugLog("Downloaded new version for form #\(form.id). New version: \(form.version)")
                    LocalStorage.shared.saveForm(sections, withId: form.id)
                }
                if updatedFormCount == formsThatNeedUpdates.count {
                    DebugLog("Done downloading new forms.")
                    callback()
                }
            }
        }
    }
    
    fileprivate func deleteUserData(forForm formId: Int, formVersion: Int) {
        let questions = DB.shared.getQuestions(forForm: formId, formVersion: formVersion)
        DB.shared.delete(questions: questions)
    }
}
