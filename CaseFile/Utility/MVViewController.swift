//
//  MVViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 23/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SafariServices
import JGProgressHUD


/// Use this class as the base class for view controllers that need to have things like the contact info on the nav bar,
/// a default title
class MVViewController: UIViewController {

    /// Connect the view that will contain the section info controller
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var headerContainerHeightConstraint: NSLayoutConstraint!
    weak var headerViewController: PatientHUDViewController?
    
    let TableSectionHeaderHeight: CGFloat = 52
    let TableSectionFooterHeight: CGFloat = 22
    
    /// Set this to false in your `viewDidLoad` method before calling super to skip adding the station info header
    var shouldDisplayHeaderContainer = true
    var shouldOverrideHeaderContent = true

    // MARK: - VC

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        configureRightButton()
        configureView()
        configureHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MVAnalytics.shared.log(event: .screen(name: String(describing: type(of: self))))
    }
    
    fileprivate func configureBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func configureRightButton() {
        let rightButton = UIBarButtonItem(image: UIImage(named: "button-menu"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(navigationMenuButtonTouched(sender:)))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc private func navigationMenuButtonTouched(sender: UIButton) {
        AppRouter.shared.showNavigationDrawer()
    }
    
    fileprivate func configureView() {
        view.backgroundColor = .appBackground
    }
    
    fileprivate func configureHeader() {
        guard shouldDisplayHeaderContainer else {
            headerContainerHeightConstraint.constant = 0;
            return
        }
        guard let headerContainer = headerContainer else {
            return
        }
        let viewModel = PatientHUDViewModel()
        if let currentPatient = ApplicationData.shared.beneficiary, shouldOverrideHeaderContent {
            viewModel.patient = currentPatient
        }
        let controller = PatientHUDViewController(model: viewModel)
        controller.view.translatesAutoresizingMaskIntoConstraints = true
        controller.willMove(toParent: self)
        addChild(controller)
        controller.view.frame = headerContainer.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerContainer.addSubview(controller.view)
        controller.didMove(toParent: self)
        headerViewController = controller
        controller.onChangeAction = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Public

    /// Call this method to add contact details to the navigation bar - the right item
    func addContactDetailsToNavBar() {
        let guideButton = UIButton(type: .custom)
        guideButton.setImage(UIImage(named:"button-guide"), for: .normal)
        guideButton.addTarget(self, action: #selector(pushGuideViewController), for: .touchUpInside)

        let callButton = UIButton(type: .custom)
        callButton.setImage(UIImage(named:"button-call"), for: .normal)
        callButton.addTarget(self, action: #selector(performCall), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [callButton, guideButton])
        stackView.axis = .horizontal
        stackView.spacing = 16
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
    }
    
    // MARK: - Actions

    @objc func pushGuideViewController() {
        MVAnalytics.shared.log(event: .tapGuide)
        if let urlString = Bundle.main.infoDictionary?["GUIDE_URL"] as? String,
            let url = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            self.navigationController?.present(safariViewController, animated: true, completion: nil)
        } else {
            let error = UIAlertController.error(withMessage: "No guide available")
            present(error, animated: true, completion: nil)
        }
    }
    
    @objc func performCall() {
        MVAnalytics.shared.log(event: .tapCall)
        if let phone = Bundle.main.infoDictionary?["SUPPORT_PHONE"] as? String {
            let phoneCallPath = "telprompt://\(phone)"
            if let phoneCallURL = NSURL(string: phoneCallPath) {
                UIApplication.shared.open(phoneCallURL as URL, options: [:], completionHandler: nil)
            }
        } else {
            let error = UIAlertController.error(withMessage: "No phone support available")
            present(error, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    
    func showFullScreenLoading(text: String?) {
        var hud = JGProgressHUD(style: .dark)
        if let applicationDataHudArray = ApplicationData.shared.object(for: ApplicationData.Keys.hud(view: self.view)) as? NSArray,
            let applicationDataHud = applicationDataHudArray[0] as? JGProgressHUD {
            hud = applicationDataHud
        }
        hud.textLabel.text = text
        ApplicationData.shared.setObject([hud] as NSObject, for: ApplicationData.Keys.hud(view: self.view))
        hud.show(in: self.navigationController?.view ?? self.view)
    }
    
    func hideFullScreenLoading(text: String, error: Bool) {
        if let hudArray = ApplicationData.shared.object(for: ApplicationData.Keys.hud(view: self.view)) as? NSArray,
            let hud = hudArray[0] as? JGProgressHUD {
            hud.textLabel.text = text
            if (error) {
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
            } else {
                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            }
            hud.dismiss(afterDelay: 1, animated: true)
            ApplicationData.shared.removeObject(for: ApplicationData.Keys.hud(view: self.view))
        }
    }
}
