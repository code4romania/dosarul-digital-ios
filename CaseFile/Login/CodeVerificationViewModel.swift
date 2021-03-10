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
    
    var isLoadingVerification: Bool = false {
        didSet {
            onUpdate?()
        }
    }
    
    var isLoadingResend: Bool = false {
        didSet {
            onUpdate?()
        }
    }
    
    var isReady: Bool {
        if let code = code, code.count == 4, !isLoadingVerification {
            return true
        }
        return false
    }
    
    func performVerification(completion: ((CodeVerificationViewModelError?) -> Void)?) {
        guard let code = code else { return }
        isLoadingVerification = true
        AppDelegate.dataSourceManager.verify2FA(code: code) { (response, error) in
            if let error = error {
                completion?(.generic(reason: error.localizedDescription))
            } else {
                if let accessToken = response?.accessToken {
                    AccountManager.shared.requiresVerification = false
                    AccountManager.shared.accessToken = accessToken
                    completion?(nil)
                } else {
                    completion?(.generic(reason: "Verification failed"))
                }
            }
            self.isLoadingVerification = false
        }
    }
    
    func resend(completion: ((CodeVerificationViewModelError?) -> Void)?) {
        isLoadingResend = true
        AppDelegate.dataSourceManager.resend2FA { (error) in
            self.isLoadingResend = false
            if let error = error {
                completion?(.generic(reason: error.localizedDescription))
            } else {
                completion?(nil)
            }
        }
    }
}
