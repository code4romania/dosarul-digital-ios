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
    var originalForms: [FormSetCellModel] = []
    var addedForms: [FormSetCellModel] = []
    var removedForms: [FormSetCellModel] = []
    var beneficiary: Beneficiary?
    
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
    
    init(beneficiary: Beneficiary?, selectionAction: FormSelectionType) {
        self.beneficiary = beneficiary
        self.selectionAction = selectionAction
        super.init()
        loadData()
    }

    func reload() {
        loadData()
    }
    
    fileprivate func loadData() {
        switch selectionAction {
        case .fillForm:
            loadBeneficiaryData()
        case .selectForm:
            originalForms = convertToViewModels(responses: loadBeneficiaryForms())
            selectedForms = convertToViewModels(responses: loadBeneficiaryForms())
            loadCachedData()
        }
    }
    
    fileprivate func loadBeneficiaryForms() -> [FormResponse]? {
        return LocalStorage
            .shared
            .forms?
            .filter({ (formResponse) -> Bool in
                return beneficiary?
                    .forms?
                    .compactMap({$0 as? Form})
                    .map({ Int($0.id) })
                    .contains(formResponse.id) ?? false
            })
    }
    
    fileprivate func loadBeneficiaryData() {
        if let beneficiaryForms = loadBeneficiaryForms() {
            forms = convertToViewModels(responses: beneficiaryForms)
        }
    }
    
    fileprivate func loadCachedData() {
        if let cached = LocalStorage.shared.forms {
            forms = convertToViewModels(responses: cached)
        }
    }
    
    fileprivate func convertToViewModels(responses: [FormResponse]?) -> [FormSetCellModel]{
        var result: [FormSetCellModel] = []
        if let objects = responses {
            // forms do not have sorting field
            //            let sorted = objects.sorted { $0.order ?? 0 < $1.order ?? 0 }
            result = objects.map { set in
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
        return result
    }
    
    func downloadFreshData() {
        isDownloadingData = true
        ApplicationData.shared.downloadUpdatedForms { error in
            self.isDownloadingData = false
            self.loadData()
            if let error = error {
                self.onDownloadComplete?(.forms(reason: error.localizedDescription))
            } else {
                self.onDownloadComplete?(nil)
            }
        }
    }
    
    func setLoading(_ loading: Bool, error: Error?) {
        onLoadingChanged?(loading, error)
    }
}
