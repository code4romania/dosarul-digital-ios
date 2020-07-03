//
//  AppRouter.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SideMenu

/// Handles navigation inside the app
class AppRouter: NSObject, NavigationDrawerDelegate, NavigationDrawerDataSource {
    
    static let shared = AppRouter()
    private let drawerWidth: CGFloat = 288
    private let navigationDrawer = NavigationDrawer()
    
    var isPad: Bool { return UIDevice.current.userInterfaceIdiom == .pad }
    var isPhone: Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    
    var window: UIWindow? {
        return AppDelegate.shared.window
    }
    var splitViewController: UISplitViewController? {
        return AppDelegate.shared.window?.rootViewController as? UISplitViewController
    }
    var navigationController: UINavigationController? {
        return splitViewController?.viewControllers.first as? UINavigationController
        ?? AppDelegate.shared.window?.rootViewController as? UINavigationController
    }
    
    override init() {
        super.init()
        navigationDrawer.dataSource = self
        navigationDrawer.delegate = self
    }
    
    func showAppEntry(animated: Bool) {
        if AccountManager.shared.accessToken != nil {
            DB.shared.saveUser(AccountManager.shared)
            showLoadingScreen()
            downloadRequiredData { [weak self] (error) in
                if error != nil {
                    self?.showErrorUpdatingData()
                    return
                }
                if OnboardingViewModel.shouldShowOnboarding {
                    AppRouter.shared.goToOnboarding()
                } else if OnboardingViewModel.shouldShowWelcome {
                    AppRouter.shared.goToWelcomeScreen()
                } else {
                    self?.goToDashboard()
                }
            }
        } else {
            goToLogin(animated: animated)
        }
        
//        RemoteConfigManager.shared.afterLoad {
//            self.checkForNewVersion()
//        }
    }
    
    func downloadRequiredData(completion:((APIError?) -> ())?) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.casefile.network.all", qos: .userInitiated, attributes: .concurrent)
        var downloadError: APIError?
        queue.async {
            // get beneficiaries
            group.enter()
            APIManager.shared.fetchBeneficiaries { (beneficiaries, error) in
                downloadError = error
                defer {
                    group.leave()
                }
                guard error == nil else {
                    return
                }
                if let beneficiaries = beneficiaries {
                    DB.shared.saveBeneficiaries(beneficiaries)
                }
            }
            // get forms
            group.enter()
            APIManager.shared.fetchForms { (forms, error) in
                downloadError = error
                group.leave()
            }
            
            
            group.notify(queue: DispatchQueue.main) {
                completion?(downloadError)
            }
        }
    }
    
    func checkForNewVersion() {
        guard RemoteConfigManager.shared.value(of: .checkAppUpdateAvailable).boolValue == true else { return }
        AppUpdateManager.shared.checkForNewVersion { (isAvailable, response, error) in
            if let error = error {
                DebugLog("Can't check for new version: \(error.localizedDescription)")
            } else {
                if isAvailable,
                    let response = response {
                    DebugLog("New Version available: \(response.version)")
                    let currentVersion = AppUpdateManager.shared.currentVersion
                    let newVersion = response.version
                    self.showNewVersionDialog(currentVersion: currentVersion, newVersion: newVersion)
                } else {
                    DebugLog("Already on latest version: \(response?.version ?? "?")")
                }
            }
        }
    }
    
    func goToLogin(animated: Bool) {
        let entryViewController = LoginViewController()
        if let window = window, animated == true {
            window.rootViewController = entryViewController
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            let duration: TimeInterval = 0.3
            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: nil)
        } else {
            window?.rootViewController = entryViewController
        }
    }

    func goToOnboarding() {
        let entryViewController = OnboardingViewController()
        let navigation = UINavigationController(rootViewController: entryViewController)
        window?.rootViewController = navigation
    }
    
    func goToWelcomeScreen() {
        OnboardingViewModel.shouldShowWelcome = false
        let onboardingViewController = WelcomeViewController()
        let navigation = UINavigationController(rootViewController: onboardingViewController)
        window?.rootViewController = navigation
    }
    
    func goToDashboard() {
        let dashboardViewController = PatientsViewController()
        let navigation = UINavigationController(rootViewController: dashboardViewController)
        self.window?.rootViewController = navigation
    }
    
    func showLoadingScreen() {
        let loadingViewController = LaunchScreenViewController(nibName: "LaunchScreenViewController-\(isPad ? "iPad" : "iPhone")", bundle: nil)
        self.window?.rootViewController = loadingViewController
    }
    
    func createSplitControllerIfNecessary() {
        guard splitViewController == nil else { return }
    }
    
    func goToChooseStation() {
        let sectionModel = SectionPickerViewModel()
        let sectionController = SectionPickerViewController(withModel: sectionModel)
        if isPad && splitViewController == nil {
            AppDelegate.shared.window?.rootViewController = UISplitViewController()
            splitViewController?.viewControllers = [UINavigationController()]
            if isPad {
                splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
            }
        } else if isPhone {
            AppDelegate.shared.window?.rootViewController = UINavigationController()
        }
        navigationController?.setViewControllers([sectionController], animated: true)
        resetDetailsPane()
    }
    
    func proceedToAuthenticated() {
        goToChooseStation()
    }

    func goToForms(from vc: UIViewController) {
        let formsModel = FormListViewModel(selectionAction: .selectForm)
        let formsVC = FormListViewController(withModel: formsModel)
        navigationController?.setViewControllers([formsVC], animated: true)
        resetDetailsPane()
    }
    
    func open(questionModel: QuestionAnswerViewModel) {
        let controller = QuestionAnswerViewController(withModel: questionModel)
        if isPad,
            let split = splitViewController {
            let navigation = UINavigationController(rootViewController: controller)
            split.showDetailViewController(navigation, sender: nil)
        } else {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openAddNote() {
        let noteModel = NoteViewModel()
        let controller = NoteViewController(withModel: noteModel)
        if isPad,
            let split = splitViewController {
            let navigation = UINavigationController(rootViewController: controller)
            split.showDetailViewController(navigation, sender: nil)
        } else {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    /// Will make the details pane go back to blank
    func resetDetailsPane() {
        guard isPad else { return }
        guard let split = AppDelegate.shared.window?.rootViewController as? UISplitViewController else { return}
        let controller = EmptyDetailsViewController()
        let navigation = UINavigationController(rootViewController: controller)
        split.showDetailViewController(navigation, sender: nil)
    }
    
    private func showNewVersionDialog(currentVersion: String, newVersion: String) {
        let alert = UIAlertController(title: "Title.NewVersion".localized,
                                      message: "AlertMessage_NewVersion".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized,
                                      style: .default,
                                      handler:
        { action in
            self.openAppUrl()
            if RemoteConfigManager.shared.value(of: .forceAppUpdate).boolValue == true {
                self.showNewVersionDialog(currentVersion: currentVersion, newVersion: newVersion)
            }
        }))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func showErrorUpdatingData() {
        let alert = UIAlertController(title: "Error".localized,
                                      message: "Error.DataDownloadFailed".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Button_Retry".localized,
                                      style: .default,
                                      handler: { action in
                                        self.showAppEntry(animated: false)
        }))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func openAppUrl() {
        let url = AppUpdateManager.shared.applicationURL
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    /// Navigation drawer
    func showNavigationDrawer() {
        let menu = SideMenuNavigationController(rootViewController: navigationDrawer)
        menu.presentationStyle = .menuSlideIn
        menu.presentationStyle.presentingEndAlpha = 0.5
        menu.leftSide = true
        menu.menuWidth = drawerWidth
        menu.statusBarEndAlpha = 0
        menu.pushStyle = .replace
        menu.navigationBar.isHidden = true
        navigationController?.present(menu, animated: true, completion: nil)
    }
    
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, viewControllerAt index: Int) -> UIViewController {
        return PatientsViewController()
    }
    
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, didTapButtonAt index: Int) {
        switch index {
        case 0:
            navigationDrawer.navigationController?.pushViewController(PatientsViewController(), animated: true)
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            AccountManager.shared.logout()
            self.showAppEntry(animated: true)
        default:
            break
        }
    }
    
    func headerImage(for navigationDrawer: NavigationDrawer) -> UIImage? {
        return UIImage(named: "logo-case-file")
    }
    
    func width(for navigationDrawer: NavigationDrawer) -> CGFloat {
        return drawerWidth
    }
    
    func numberOfViewControllers(in navigationDrawer: NavigationDrawer) -> Int {
        return 5
    }
    
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, titleForButtonAt index: Int) -> String? {
        switch index {
        case 0:
            return "Label_MyPatients".localized
        case 1:
            return "Label_Info".localized
        case 2:
            return "Label_Contacts".localized
        case 3:
            return "Label_Settings".localized
        case 4:
            return "Label_LogOut".localized
        default:
            return nil
        }
    }
    
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, imageForButtonAt index: Int) -> UIImage? {
        switch index {
        case 0:
            return UIImage(named: "icon-drawer-home")
        case 1:
            return UIImage(named: "icon-drawer-info")
        case 2:
            return UIImage(named: "icon-drawer-contacts")
        case 3:
            return UIImage(named: "icon-drawer-settings")
        case 4:
            return UIImage(named: "icon-drawer-logout")
        default:
            return nil
        }
    }
    
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, positionForButtonAt index: Int) -> NavigationDrawerItemPosition {
        switch index {
        case 3:
            fallthrough
        case 4:
            return .bottom
        default:
            return .top
        }
    }
    
}
