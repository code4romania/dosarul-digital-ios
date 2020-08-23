//
//  AccountManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper


protocol AccountManagerType: NSObject {
    /// The logged in user's access token. Nil means unauthenticated
    var accessToken: String? { get set }
    
    /// How long the access token is valid
    var expiresIn: Int? { get set}
    
    /// The user's email
    var email: String? { get set }
    
    /// First login
    var firstLogin: Bool? { get set }
    
    /// Requires verification
    var requiresVerification: Bool? { get set }
    
    func logout()
}


class AccountManager: NSObject, AccountManagerType {
    
    enum SettingKey {
        static let token = "token"
        static let email = "email"
        static let expiresIn = "expires_in"
        static let requiresVerification = "requires_verification"
    }
    
    static let shared: AccountManagerType = AccountManager()
    
    var accessToken: String? {
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: SettingKey.token)
            } else {
                KeychainWrapper.standard.removeObject(forKey: SettingKey.token)
            }
        } get {
            return KeychainWrapper.standard.string(forKey: SettingKey.token)
        }
    }
    
    var email: String? {
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: SettingKey.email)
            } else {
                KeychainWrapper.standard.removeObject(forKey: SettingKey.email)
            }
        } get {
            return KeychainWrapper.standard.string(forKey: SettingKey.email)
        }
    }
    
    var expiresIn: Int? {
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: SettingKey.expiresIn)
            } else {
                KeychainWrapper.standard.removeObject(forKey: SettingKey.expiresIn)
            }
        } get {
            return KeychainWrapper.standard.integer(forKey: SettingKey.expiresIn)
        }
    }
    
    var requiresVerification: Bool? {
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: SettingKey.requiresVerification)
            } else {
                KeychainWrapper.standard.removeObject(forKey: SettingKey.requiresVerification)
            }
        } get {
            return KeychainWrapper.standard.bool(forKey: SettingKey.requiresVerification)
        }
    }
    
    var firstLogin: Bool?
    
    func logout() {
        accessToken = nil
        email = nil
        expiresIn = nil
        firstLogin = nil
        requiresVerification = nil
    }
}
