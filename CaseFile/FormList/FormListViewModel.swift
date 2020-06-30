//
//  FormSetsViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 22/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum FormListViewModelError: Error {
    case forms(reason: String)
    
    var localizedDescription: String {
        // TODO: localize
        switch self {
        case .forms(let reason):
            return "Could not download forms. " + reason
        }
    }
}

enum FormSelectionType {
    case fillForm
    case selectForm
}

class FormListViewModel: NSObject {
    var forms: [FormSetCellModel] = []
    
    var selectedForms: [FormSetCellModel] = [] {
        didSet {
            onSelectionStateChanged?()
        }
    }
    
    /// Check this flag, it tells you what forms have been selected in selection mode
    var selectionAction: FormSelectionType
    
    /// Check this flag, it tells you the download state
    var isDownloadingData: Bool = false
    
    /// Check this flag, it tells you whether we're syncing or not
    var isSynchronising: Bool = false
    
    /// Get notified when new sets are downloaded
    var onDownloadComplete: ((FormListViewModelError?) -> Void)?

    /// Get notified when downloading state has changed
    var onDownloadingStateChanged: (() -> Void)?

    /// Get notified when syncing state has changed
    var onSyncingStateChanged: (() -> Void)?
    
    /// Get notified when selected forms change
    var onSelectionStateChanged: (() -> Void)?
    
    /// Get notified when loading state changes
    var onLoadingChanged: ((Bool, Error?) -> Void)?
    
    init(selectionAction: FormSelectionType) {
        self.selectionAction = selectionAction
        super.init()
        loadCachedData()
    }

    func reload() {
        loadCachedData()
    }
    
    fileprivate func loadCachedData() {
        if let cached = LocalStorage.shared.forms {
            convertToViewModels(responses: cached)
        }
    }
    
    fileprivate func convertToViewModels(responses: [FormResponse]?) {
        if let objects = responses {
            // forms do not have sorting field
//            let sorted = objects.sorted { $0.order ?? 0 < $1.order ?? 0 }
            forms = objects.map { set in
                let formCodePrefix = set.code.first != nil ? String(set.code.first!).lowercased() : ""
                let image = UIImage(named: "icon-formset-\(formCodePrefix)") ?? UIImage(named: "icon-formset-default")
                let answeredQuestions = DB.shared.getAnsweredQuestions(inFormWithCode: set.code).count
                let formSections = LocalStorage.shared.loadForm(withId: set.id)
                let totalQuestions = formSections?.reduce([QuestionResponse](), { $0 + $1.questions }).count ?? 0
                let progress = totalQuestions > 0 ? CGFloat(answeredQuestions) / CGFloat(totalQuestions) : 0
                return FormSetCellModel(
                    id: set.id,
                    icon: image ?? UIImage(), // just in case
                    title: set.description,
                    code: set.code.uppercased(),
                    progress: progress,
                    answeredOutOfTotalQuestions: "\(answeredQuestions)/\(totalQuestions)",
                    selectionType: selectionAction)
            }
        }
    }
    
    func downloadFreshData() {
        isDownloadingData = true
        ApplicationData.shared.downloadUpdatedForms { error in
            self.isDownloadingData = false
            self.convertToViewModels(responses: LocalStorage.shared.forms)
            if let error = error {
                self.onDownloadComplete?(.forms(reason: error.localizedDescription))
            } else {
                self.onDownloadComplete?(nil)
            }
        }
    }
    
    func createPatient() {
        setLoading(true, error: nil)
    }
    
    fileprivate func setLoading(_ loading: Bool, error: Error?) {
        onLoadingChanged?(loading, error)
    }
}
