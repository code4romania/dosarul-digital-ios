//
//  PreferencesManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit


protocol PreferencesManagerType: NSObject {
    var wasOnboardingShown: Bool { get set }
    var county: String? { get set }
    var section: Int? { get set }
    var sectionName: String? { get set }
    var languageLocale: String? { get set }
    var languageName: String? { get set }
    var isNewApp: Bool { get }
}

class PreferencesManager: NSObject, PreferencesManagerType {
    static let shared: PreferencesManagerType = PreferencesManager()
    
    enum SettingKey: String {
        case wasOnboardingShown = "PreferenceWasOnboardingShown"
        case county = "PreferenceCounty"
        case section = "PreferenceSectionId"
        case sectionName = "PreferenceSectionName"
        case languageLocale = "PreferenceLanguageLocale"
        case languageName = "PreferenceLanguageName"
        case newAppToken = "PreferenceAppToken"
    }
    
    var county: String? {
        set {
            setValue(newValue, forKey: .county)
        } get {
            return getValue(forKey: .county) as? String
        }
    }

    var section: Int? {
        set {
            setValue(newValue, forKey: .section)
        } get {
            return getValue(forKey: .section) as? Int
        }
    }
    
    var sectionName: String? {
        set {
            setValue(newValue, forKey: .sectionName)
        } get {
            return getValue(forKey: .sectionName) as? String
        }
    }
    
    var wasOnboardingShown: Bool {
        set {
            setValue(newValue, forKey: .wasOnboardingShown, suffix: AccountManager.shared.email!)
        } get {
            return getValue(forKey: .wasOnboardingShown, suffix: AccountManager.shared.email!) as? Bool ?? false
        }
    }
    
    var languageLocale: String? {
        set {
            setValue(newValue, forKey: .languageLocale)
        } get {
            return getValue(forKey: .languageLocale) as? String
        }
    }
    
    var languageName: String? {
        set {
            setValue(newValue, forKey: .languageName)
        } get {
            return getValue(forKey: .languageName) as? String
        }
    }
    
    var isNewApp: Bool {
        get {
            var newApp = false
            if getValue(forKey: .newAppToken) == nil {
                setValue(UUID().uuidString, forKey: .newAppToken)
                newApp = true
            }
            return newApp
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func setValue(_ value: Any?, forKey key: SettingKey) {
        self .setValue(value, forKey: key, suffix: "")
    }
    
    fileprivate func setValue(_ value: Any?, forKey key: SettingKey, suffix: String) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key.rawValue + suffix)
        } else {
            UserDefaults.standard.removeObject(forKey: key.rawValue + suffix)
        }
        UserDefaults.standard.synchronize()
    }

    fileprivate func getValue(forKey key: SettingKey) -> Any? {
        return self .getValue(forKey: key, suffix: "")
    }
    
    fileprivate func getValue(forKey key: SettingKey, suffix: String) -> Any? {
           return UserDefaults.standard.object(forKey: key.rawValue + suffix)
       }
}
