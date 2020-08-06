//
//  FormDateViewModel.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 05/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class FormDateViewModel: NSObject {
    fileprivate var form: FormResponse
    let code: String
    
    var title: String {
        return form.description
    }
    
    var date: Date? {
        didSet {
            if let date = date {
                ApplicationData.shared.setObject([date] as NSObject, for: .patientFormCompletionDate)
            } else {
                ApplicationData.shared.removeObject(for: .patientFormCompletionDate)
            }
            onUpdate?()
        }
    }
    
    var onUpdate: (() -> ())?
       
    init?(withFormUsingCode code: String) {
        guard let form = LocalStorage.shared.getFormSummary(withCode: code) else { return nil }
        self.form = form
        self.code = code
        super.init()
    }
    
    deinit {
        ApplicationData.shared.removeObject(for: .patientFormCompletionDate)
    }
    
}
