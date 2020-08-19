//
//  LoginViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 02/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import KeyboardLayoutGuide

class LoginViewController: MVViewController {
    
    var model: LoginViewModel = LoginViewModel()
    
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var loginDescription: UILabel!
    @IBOutlet weak var vmLogoView: UIView!
    @IBOutlet weak var vmLogoPlainView: UIImageView!
    @IBOutlet weak var vmLogoBubblesView: UIImageView!
    @IBOutlet weak var outerCardContainer: UIView!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: ActionButton!
    @IBOutlet weak var backgroundPlainAspectRatioIpadConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundBubblesAspectRatioIpadConstraint: NSLayoutConstraint!
    var loginViewBottomToKeyboardConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setupStaticText()
        bindToUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateInterface()
    }
    
    fileprivate func bindToUpdates() {
        model.onUpdate = { [weak self] in
            self?.updateInterface()
        }
    }
    
    fileprivate func configureViews() {
        loginViewBottomToKeyboardConstraint = outerCardContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor,
                                                                                         constant: -32)
        outerCardContainer.layer.shadowColor = UIColor.cardDarkerShadow.cgColor
        outerCardContainer.layer.shadowOffset = .zero
        outerCardContainer.layer.shadowRadius = Configuration.shadowRadius
        outerCardContainer.layer.shadowOpacity = Configuration.shadowOpacity
        outerCardContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        outerCardContainer.backgroundColor = .cardBackground
        
        emailContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        emailContainer.layer.borderColor = UIColor.textViewContainerBorder.cgColor
        emailContainer.layer.borderWidth = 1
        passwordContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        passwordContainer.layer.borderColor = UIColor.textViewContainerBorder.cgColor
        passwordContainer.layer.borderWidth = 1
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            vmLogoPlainView.image = UIImage(named: "bg-login-ipad")
            vmLogoBubblesView.image = UIImage(named: "bg-login-over-ipad")
            backgroundPlainAspectRatioIpadConstraint.isActive = true
            backgroundBubblesAspectRatioIpadConstraint.isActive = true
        case .phone:
            vmLogoPlainView.image = UIImage(named: "bg-login")
            vmLogoBubblesView.image = UIImage(named: "bg-login-over")
            backgroundPlainAspectRatioIpadConstraint.isActive = false
            backgroundBubblesAspectRatioIpadConstraint.isActive = false
        default:
            break
        }
        view.layoutIfNeeded()
    }
    
    // MARK: - UI
    
    fileprivate func updateLoginButtonState() {
        loginButton.isEnabled = model.isReady
        loginButton.setTitle(model.buttonTitle, for: .normal)
    }
    
    fileprivate func updateInterface() {
        updateLoginButtonState()
        emailTextField.text = model.emailAddress
        passwordTextField.text = model.password
        if model.isLoading {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
    }
    
    private func setupStaticText() {
        loginTitle.text = "Label_Login".localized
        loginDescription.text = "Label_Login_Description".localized
        emailTextField.placeholder = "Label_EmailTextInput_Placeholder".localized
        passwordTextField.placeholder = "Label_PasswordTextInput_Placeholder".localized
        
//        updateVersionLabel()
    }
    
    private func updateVersionLabel() {
        guard let info = Bundle.main.infoDictionary else { return }
        let version = info["CFBundleShortVersionString"] ?? "1.0"
        let build = info["CFBundleVersion"] ?? "1"
        var versionString = "v\(version)"
        #if DEBUG
        versionString += "(\(build))"
        #endif
    }
    
    fileprivate func setVMLogo(visible: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.vmLogoView.alpha = visible ? 1 : 0
                self.loginViewBottomToKeyboardConstraint.isActive = !visible
            }
        } else {
            vmLogoView.alpha = visible ? 1 : 0
            loginViewBottomToKeyboardConstraint.isActive = visible
        }
    }
    
    // MARK: - Actions
    
    func login() {
        guard model.isReady else { return }
        model.login { [weak self] error in
            if let error = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
                MVAnalytics.shared.log(event: .loginFailed(error: error.localizedDescription))
            } else {
                self?.proceedToNextScreen()
                // TODO: Do we ask for push notifications?
//                self?.askForPushNotificationsPermissions()
            }
        }
    }
    
    @objc private func toggleCodeInputVisibility(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = sender.isSelected
    }
    
    func askForPushNotificationsPermissions() {
        // always ask for notifications so that we can detect token changes
        NotificationsManager.shared.registerForRemoteNotifications()
    }

    @IBAction func handleLoginButtonTap(_ sender: Any) {
        login()
    }
    
    func proceedToNextScreen() {
        navigationController?.pushViewController(CodeVerificationViewController(), animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if AppRouter.shared.isPhone {
            setVMLogo(visible: false, animated: true)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if AppRouter.shared.isPhone {
                setVMLogo(visible: true, animated: true)
            }
            login()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updated = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        switch textField {
        case emailTextField:
            model.emailAddress = updated
        case passwordTextField:
            model.password = updated
        default:
            break
        }
        updateLoginButtonState()
        return true
    }
}
