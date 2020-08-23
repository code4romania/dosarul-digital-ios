//
//  Alerts.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func error(withMessage message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Error".localized,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        return alert
    }
    
    static func error(withMessage message: String, completion: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "Error".localized,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: completion))
        return alert
    }
    
    static func info(withMessage message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        return alert
    }
    
    func showOnKeyWindow() {
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        if let presentedViewController = rootViewController?.presentedViewController {
            rootViewController = presentedViewController;
        }
        rootViewController?.present(self, animated: true, completion: nil)
    }
}
