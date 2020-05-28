//
//  OnboardingViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 03/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class OnboardingViewModel: NSObject {
    static var shouldShowOnboarding: Bool { return !PreferencesManager.shared.wasOnboardingShown }
    
    let navigationImage = UIImage(named: "logo-case-file-white")
    let image = UIImage(named: "onboarding")
    var topText = "Onboarding.Title".localized
    var mainText = "Onboarding.Description".localized
    var proceed = "Onboarding.Continue".localized
    
}
