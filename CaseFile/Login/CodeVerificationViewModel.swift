//
//  LoginViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 02/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum CodeVerificationViewModelError: Error {
    case generic(reason: String)
    
    var localizedDescription: String {
        switch self {
        case .generic(let reason): return reason
        }
    }
}

class CodeVerificationViewModel: NSObject {
    var code: String?
    
    var onUpdate: (() -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            onUpdate?()
        }
    }
    
    var isReady: Bool {
        if let code = code, code.count == 4, !isLoading {
            return true
        }
        return false
    }
    
    func performVerification(completion: ((CodeVerificationViewModelError?) -> Void)?) {
        guard let code = code else { return }
        isLoading = true
        AppDelegate.dataSourceManager.verify2FA(code: code) { (response, error) in
            if let error = error {
                completion?(.generic(reason: error.localizedDescription))
            } else {
                if let success = response?.success, success == true {
                    completion?(nil)
                } else {
                    completion?(.generic(reason: "Verification failed"))
                }
            }
            self.isLoading = false
        }
    }
}
