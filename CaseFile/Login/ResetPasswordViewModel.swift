//
//  LoginViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 02/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum ResetPasswordModelError: Error {
    case generic(reason: String)
    
    var localizedDescription: String {
        switch self {
        case .generic(let reason): return reason
        }
    }
}

class ResetPasswordViewModel: NSObject {
    var password: String?
    var passwordConfirmation: String?
    
    var onUpdate: (() -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            onUpdate?()
        }
    }
    
    var isReady: Bool {
        guard isValidPassword,
            password == passwordConfirmation,
            !isLoading else {
                return false
        }
        return true
    }
    
    var isValidPassword: Bool {
        guard let password = password else {
            return false
        }
        let stricterFilterString = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
        return passwordPredicate .evaluate(with: password)
    }
    
    var buttonTitle: String {
        isLoading ? "" : "Button_Change".localized
    }
    
    func resetPassword(completion: ((ResetPasswordModelError?) -> Void)?) {
        guard let password = password, let passwordConfirmation = passwordConfirmation else {
            completion?(ResetPasswordModelError.generic(reason: "Password mismatch"))
            return
        }
        isLoading = true
        onUpdate?()
        AppDelegate.dataSourceManager.resetPassword(password: password, confirmPassword: passwordConfirmation) { (error) in
            if let error = error {
                completion?(.generic(reason: error.localizedDescription))
            } else {
                completion?(nil)
            }
            self.isLoading = false
            self.onUpdate?()
        }
    }
}
