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
        if AccountManager.shared.accessToken != nil && AccountManager.shared.requiresVerification == false {
            DB.shared.saveUser(AccountManager.shared, persistent: true)
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
            AppDelegate.dataSourceManager.fetchBeneficiaries { (beneficiaries, error) in
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
            AppDelegate.dataSourceManager.fetchForms { (forms, error) in
                downloadError = error
                group.leave()
            }
            
            // get answers
            
            // get notes
            
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
        let navController = UINavigationController(rootViewController: entryViewController)
        navController.setNavigationBarHidden(true, animated: false)
        if let window = window, animated == true {
            window.rootViewController = navController
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            let duration: TimeInterval = 0.3
            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: nil)
        } else {
            window?.rootViewController = navController
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
        let model = PatientViewModel(operation: .view)
        let dashboardViewController = PatientsViewController(model: model)
        if let navigationController = navigationController {
            navigationController.setViewControllers([dashboardViewController], animated: true)
        } else {
            let navigation = UINavigationController(rootViewController: dashboardViewController)
            self.window?.rootViewController = navigation
        }
    }
    
    func logout() {
        AccountManager.shared.logout()
        showAppEntry(animated: true)
    }
    
    func logout(message: String) {
        UIAlertController.error(withMessage: message) { (_) in
            AccountManager.shared.logout()
            self.showAppEntry(animated: true)
        }.showOnKeyWindow()
    }
    
    func showLoadingScreen() {
        let loadingViewController = LaunchScreenViewController(nibName: "LaunchScreenViewController-\(isPad ? "iPad" : "iPhone")", bundle: nil)
        self.window?.rootViewController = loadingViewController
    }
    
    func createSplitControllerIfNecessary() {
        guard splitViewController == nil else { return }
    }

    func goToFormsSelection(beneficiary: Beneficiary?, from vc: UIViewController) {
        let formsModel = FormListViewModel(beneficiary: beneficiary, selectionAction: .selectForm)
        let formsVC = FormListViewController(withModel: formsModel)
        if let navigationController = vc.navigationController ?? navigationController {
            navigationController.pushViewController(formsVC, animated: true)
//        resetDetailsPane()
        } else {
            vc.present(formsVC, animated: true, completion: nil)
        }
    }
    
    func goToFormsFill(beneficiary: Beneficiary?, from vc: UIViewController) {
        let formsModel = FormListViewModel(beneficiary: beneficiary, selectionAction: .fillForm)
        let formsVC = FormListViewController(withModel: formsModel)
        if let navigationController = vc.navigationController ?? navigationController {
            navigationController.pushViewController(formsVC, animated: true)
            //        resetDetailsPane()
        } else {
            vc.present(formsVC, animated: true, completion: nil)
        }
    }
    
    func goToFormDate(withId id: Int, for beneficiary: Beneficiary?, from viewController: UIViewController) {
        guard let formDateModel = FormDateViewModel(withFormUsingId: id) else {
            let message = "Error: can't load question list model for form with id \(id)"
            let alert = UIAlertController.error(withMessage: message)
            viewController.present(alert, animated: true, completion: nil)
            return
        }
        guard let beneficiary = beneficiary else {
            let message = "Error: missing beneficiary"
            let alert = UIAlertController.error(withMessage: message)
            viewController.present(alert, animated: true, completion: nil)
            return
        }
        if let formDate = DB.shared.getAnswers(inFormWithId: id, beneficiary: beneficiary).first?.fillDate {
            formDateModel.date = formDate
        }
        let formDateVC = FormDateViewController(withModel: formDateModel)
        if let navigationController = viewController.navigationController {
            navigationController.pushViewController(formDateVC, animated: true)
        } else {
            viewController.present(formDateVC, animated: true, completion: nil)
        }
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
        let noteModel = NoteViewModel(for: nil, with: nil)
        openAddNote(noteModel: noteModel)
    }
    
    func openAddNote(noteModel: NoteViewModel?) {
        guard let noteModel = noteModel else {
            return
        }
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
        let model = PatientViewModel(operation: .view)
        return PatientsViewController(model: model)
    }
    
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, didTapButtonAt index: Int) {
        switch index {
        case 0:
            let model = PatientViewModel(operation: .view)
            let viewController = PatientsViewController(model: model)
            navigationDrawer.navigationController?.pushViewController(viewController, animated: true)
        case 1:
            navigationDrawer.navigationController?.pushViewController(InfoViewController(), animated: true)
        case 2:
            navigationDrawer.navigationController?.pushViewController(ContactsViewController(), animated: true)
        case 3:
            break
        case 4:
            logout()
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
