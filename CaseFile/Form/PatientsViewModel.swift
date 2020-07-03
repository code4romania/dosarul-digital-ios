//
//  PatientsViewModel.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 28/05/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class PatientsViewModel: NSObject {
    var navigationTitle = "Title.Patients".localized
    
    var dataSource: [Beneficiary]?
    
    override init() {
        super.init()
        reloadSource()
    }

    func reloadSource() {
        dataSource = DB.shared.currentUser?.beneficiaries?
            .compactMap({ $0 as? Beneficiary })
            .sorted(by: { $0.id > $1.id })
    }
    
}
