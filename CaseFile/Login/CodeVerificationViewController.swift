//
//  LoginViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 02/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import KeyboardLayoutGuide

class CodeVerificationViewController: MVViewController {
    
    var model: CodeVerificationViewModel = CodeVerificationViewModel()
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var viewDescription: UILabel!
    @IBOutlet weak var vmLogoView: UIView!
    @IBOutlet weak var vmLogoPlainView: UIImageView!
    @IBOutlet weak var vmLogoBubblesView: UIImageView!
    @IBOutlet weak var outerCardContainer: UIView!
    @IBOutlet weak var codeContainer: UIView!
    @IBOutlet weak var instructionsContainer: UIView!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var resendCodeButton: AttachButton!
    @IBOutlet weak var verifyButton: ActionButton!
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
        updateInterface()
    }
    
    fileprivate func bindToUpdates() {
        model.onUpdate = { [weak self] in
            self?.updateInterface()
        }
    }
    
    fileprivate func configureViews() {
        
        codeTextField.defaultTextAttributes.updateValue(13.8, forKey: NSAttributedString.Key.kern)
        codeTextField.becomeFirstResponder()
        
        loginViewBottomToKeyboardConstraint = outerCardContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor,
                                                                                         constant: -32)
        outerCardContainer.layer.shadowColor = UIColor.cardDarkerShadow.cgColor
        outerCardContainer.layer.shadowOffset = .zero
        outerCardContainer.layer.shadowRadius = Configuration.shadowRadius
        outerCardContainer.layer.shadowOpacity = Configuration.shadowOpacity
        outerCardContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        outerCardContainer.backgroundColor = .cardBackground
        
        codeContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        codeContainer.layer.borderColor = UIColor.textViewContainerBorder.cgColor
        codeContainer.layer.borderWidth = 1
        
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
        verifyButton.isEnabled = model.isReady
        verifyButton.setTitle(model.isLoading ? "" : "Button_Verify".localized, for: .normal)
    }
    
    fileprivate func updateInterface() {
        updateLoginButtonState()
        if model.isReady {
            codeTextField.resignFirstResponder()
        }
        if model.isLoading {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
    }
    
    private func setupStaticText() {
        viewTitle.text = "Label_Verify".localized
        viewDescription.text = "Label_Verify_Description".localized
        instructionsLabel.text = "Label_Verify_Instruction".localized
        resendCodeButton.setTitle("Button_Resend".localized, for: .normal)
        verifyButton.setTitle("Button_Verify".localized, for: .normal)
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
    
    func verify() {
        guard model.isReady else { return }
        model.performVerification { [weak self] error in
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
    }

    @IBAction func handleLoginButtonTap(_ sender: Any) {
        verify()
    }
    
    func proceedToNextScreen() {
        if AccountManager.shared.firstLogin ?? false {
            navigationController?.pushViewController(ResetPasswordViewController(), animated: true)
        } else {
            OnboardingViewModel.shouldShowWelcome = true
            AppRouter.shared.showAppEntry(animated: true)
        }
    }
}

extension CodeVerificationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if AppRouter.shared.isPhone {
            setVMLogo(visible: false, animated: true)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if AppRouter.shared.isPhone {
            setVMLogo(visible: true, animated: true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 4
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length <= maxLength {
            model.code = String(newString)
            updateLoginButtonState()
            return true
        }
        return false
    }
}
