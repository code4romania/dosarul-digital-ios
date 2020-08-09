//
//  LoginViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 02/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import KeyboardLayoutGuide

class ResetPasswordViewController: MVViewController {
    
    var model = ResetPasswordViewModel()
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var viewDescription: UILabel!
    @IBOutlet weak var vmLogoView: UIView!
    @IBOutlet weak var vmLogoPlainView: UIImageView!
    @IBOutlet weak var vmLogoBubblesView: UIImageView!
    @IBOutlet weak var outerCardContainer: UIView!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var passwordConfirmationContainer: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextfield: UITextField!
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
        
        passwordContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        passwordContainer.layer.borderColor = UIColor.textViewContainerBorder.cgColor
        passwordContainer.layer.borderWidth = 1
        passwordConfirmationContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        passwordConfirmationContainer.layer.borderColor = UIColor.textViewContainerBorder.cgColor
        passwordConfirmationContainer.layer.borderWidth = 1
        
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
        passwordTextField.text = model.password
        passwordConfirmationTextfield.text = model.passwordConfirmation
        if model.isLoading {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
    }
    
    private func setupStaticText() {
        viewTitle.text = "Label_Password_Change".localized
        viewDescription.text = "Label_Password_Change_Description".localized
        passwordTextField.placeholder = "Label_Password_Change_TextInput_Placeholder".localized
        passwordConfirmationTextfield.placeholder = "Label_Password_Change_Confirmation_TextInput_Placeholder".localized
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
    
    func resetPassword() {
        guard model.isReady else { return }
        model.resetPassword { [weak self] (error) in
            if let error = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
                MVAnalytics.shared.log(event: .loginFailed(error: error.localizedDescription))
            } else {
                self?.proceedToNextScreen()
            }
        }
    }
    
    @objc private func toggleCodeInputVisibility(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordConfirmationTextfield.isSecureTextEntry = sender.isSelected
    }
    
    func askForPushNotificationsPermissions() {
        // always ask for notifications so that we can detect token changes
        NotificationsManager.shared.registerForRemoteNotifications()
    }

    @IBAction func handleLoginButtonTap(_ sender: Any) {
        resetPassword()
    }
    
    func proceedToNextScreen() {
        OnboardingViewModel.shouldShowWelcome = true
        AppRouter.shared.showAppEntry(animated: true)
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if AppRouter.shared.isPhone {
            setVMLogo(visible: false, animated: true)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            passwordConfirmationTextfield.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if AppRouter.shared.isPhone {
                setVMLogo(visible: true, animated: true)
            }
            resetPassword()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        switch textField {
        case passwordTextField:
            model.password = updatedValue
        case passwordConfirmationTextfield:
            model.passwordConfirmation = updatedValue
        default:
            break
        }
        updateLoginButtonState()
        return true
    }
}
