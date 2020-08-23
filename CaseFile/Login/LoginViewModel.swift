//
//  LoginViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 02/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum LoginViewModelError: Error {
    case generic(reason: String)
    
    var localizedDescription: String {
        switch self {
        case .generic(let reason): return reason
        }
    }
}

class LoginViewModel: NSObject {
    var emailAddress: String?
    var password: String?
    
    var onUpdate: (() -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            onUpdate?()
        }
    }
    
    var isReady: Bool {
        guard let emailAddress = emailAddress,
            let password = password,
            emailAddress.isEmail,
            password.count != 0,
            !isLoading else {
                return false
        }
        return true
    }
    
    var buttonTitle: String {
        isLoading ? "" : "Button_Login".localized
    }
    
    override init() {
        super.init()
        #if DEBUG
        prepopulateTestData()
        #endif
    }
    
    fileprivate func prepopulateTestData() {
        // set these in your local config if you want the phone and pin to be prepopulated,
        // saving you a bunch of typing/pasting
        let prefilledPhone = Bundle.main.infoDictionary?["TEST_EMAIL"] as? String ?? ""
        let prefilledPin = Bundle.main.infoDictionary?["TEST_PASSWORD"] as? String ?? ""
        if prefilledPin.count > 0 {
            self.emailAddress = prefilledPhone
            self.password = prefilledPin
            onUpdate?()
        }
    }
    
    func login(then callback: @escaping (LoginViewModelError?) -> Void) {
        guard let phone = emailAddress, let pin = password else { return }
        isLoading = true
        onUpdate?()
        AppDelegate.dataSourceManager.login(email: phone, password: pin) { (user, error) in
            if let error = error {
                callback(.generic(reason: error.localizedDescription))
            } else {
                // Save user to account manager singleton
                AccountManager.shared.email = user?.email
                AccountManager.shared.accessToken = user?.accessToken
                AccountManager.shared.expiresIn = user?.expiresIn
                AccountManager.shared.firstLogin = user?.firstLogin
                AccountManager.shared.requiresVerification = true
                callback(nil)
            }
            self.isLoading = false
            self.onUpdate?()
        }
    }
}
