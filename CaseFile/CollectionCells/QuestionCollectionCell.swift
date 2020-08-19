//
//  QuestionCollectionCell.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class QuestionCollectionCell: UICollectionViewCell, UITextViewDelegate {
    
    static let reuseIdentifier = "QuestionCollectionCell"
    override var reuseIdentifier: String? { return type(of: self).reuseIdentifier }
    
    var currentModel: QuestionAnswerCellModel?
    var shouldChangeText: Bool = false
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var statusContainer: UIStackView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var questionCodeLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var answersStackView: UIStackView!
    @IBOutlet weak var attachButton: AttachButton!
    
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    
    typealias QuestionCollectionCellAnswerText = (_ model: inout QuestionAnswerCellModel, _ answerIndex: Int, _ answerText: String) -> Void
    
    typealias QuestionCollectionCellAnswerSelection = (_ model: inout QuestionAnswerCellModel, _ answerIndex: Int) -> Void
    
    typealias QuestionCollectionCellAddNote = (_ model: inout QuestionAnswerCellModel) -> Void
    
    /// Set this to be called back when the user taps an answer
    var onAnswerSelection: QuestionCollectionCellAnswerSelection?
    
    /// Set this to be called back when an answer text is changed
    var onAnswerText: QuestionCollectionCellAnswerText?
    
    /// Set this to be called back when the user taps on Add Note
    var onAddNote: QuestionCollectionCellAddNote?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        container.layer.shadowColor = UIColor.cardDarkerShadow.cgColor
        container.layer.shadowRadius = Configuration.shadowRadius
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = .zero
        configureKeyboardEvent()
    }
    
    func configureKeyboardEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow() {
        topConstraint.isActive = true
        centerConstraint.isActive = false
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide() {
        topConstraint.isActive = false
        centerConstraint.isActive = true
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

    func update(withModel model: QuestionAnswerCellModel) {
        currentModel = model
        questionCodeLabel.text = model.questionCode.uppercased()
        questionTextLabel.text = model.questionText + (model.isMandatory ? "*" : "")
        
        answersStackView.arrangedSubviews.forEach {
            answersStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        for (index, answer) in model.questionAnswers.enumerated() {
            // handle new types
            switch model.type {
            case .date:
                let button = DropdownButton(type: .custom)
                button.heightAnchor.constraint(equalToConstant: 44).isActive = true
                button.setContentCompressionResistancePriority(.required, for: .vertical)
                button.setContentHuggingPriority(.required, for: .vertical)
                if let selectedDate = answer.userText {
                    // convert to date
                    let date = APIManager.shared.apiDateFormatter.date(from: selectedDate)
                    button.value = date?.toString(dateFormatter: DateFormatter.defaultDateFormatter)
                }
                button.addTarget(self, action: #selector(handleAnswerButtonTap(_:)), for: .touchUpInside)
                answersStackView.addArrangedSubview(button)
            case .text:
                let textView = TextView()
                configureTextView(textView: textView, height: 165)
                configureKeyboardInputAccessoryView(textView: textView)
                textView.text = answer.userText
                textView.onTextChanged = { [weak textView] in
                    guard let text = textView?.text, self.currentModel != nil else { return }
                    self.onAnswerText?(&self.currentModel!, index, text)
                }
                answersStackView.addArrangedSubview(textView)
            case .number:
                let textView = TextView()
                configureTextView(textView: textView, height: 30)
                configureKeyboardInputAccessoryView(textView: textView)
                textView.numberOfCharacters = model.numberOfCharacters
                textView.keyboardType = .numberPad
                textView.text = answer.userText
                textView.onTextChanged = { [weak textView] in
                    guard let text = textView?.text, self.currentModel != nil else { return }
                    self.onAnswerText?(&self.currentModel!, index, text)
                }
                answersStackView.addArrangedSubview(textView)
            default:
                let button = ChooserButton(type: .custom)
                button.heightAnchor.constraint(equalToConstant: 44).isActive = true
                button.setContentCompressionResistancePriority(.required, for: .vertical)
                button.setContentHuggingPriority(.required, for: .vertical)
                button.setTitle(answer.text, for: .normal)
                if answer.isFreeText {
                    let icon = answer.userText != nil ? #imageLiteral(resourceName: "icon-check") : nil
                    button.setImage(icon, for: .normal)
                }
                button.isSelected = answer.isSelected
                button.addTarget(self, action: #selector(handleAnswerButtonTap(_:)), for: .touchUpInside)
                answersStackView.addArrangedSubview(button)
            }
        }
        
        statusContainer.isHidden = !model.isSaved
        
        if model.isSynced {
            statusLabel.text = "Label_Synced".localized
            statusIcon.image = #imageLiteral(resourceName: "icon-check")
        } else if model.isSaved {
            statusLabel.text = "Label_Saved".localized
            statusIcon.image = #imageLiteral(resourceName: "icon-check-greyed")
        }
        
        attachButton.setTitle("Button_AddNoteToQuestion".localized, for: .normal)
        layoutIfNeeded()
    }
    
    func configureTextView(textView: TextView, height: CGFloat) {
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.heightAnchor.constraint(equalToConstant: height).isActive = true
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.backgroundColor = UIColor.textViewContainerBg
        textView.layer.borderColor = UIColor.textViewContainerSolidBorder.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        textView.delegate = self
    }
    
    func configureKeyboardInputAccessoryView(textView: UITextView) {
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 32))
        keyboardToolbar.translatesAutoresizingMaskIntoConstraints = false
        keyboardToolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel".localized,
                                         style: .plain,
                                         target: self,
                                         action: #selector(cancelEdit))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                         target: nil,
                                         action: nil)
        let doneButton = UIBarButtonItem(title: "Button_Submit".localized,
                                            style: .done,
                                            target: self,
                                            action: #selector(finishEdit))
        keyboardToolbar.items = [cancelButton, flexButton, doneButton]
        textView.inputAccessoryView = keyboardToolbar;
    }
    
    @objc func cancelEdit() {
        shouldChangeText = false
        self.endEditing(false)
    }
    
    @objc func finishEdit() {
        shouldChangeText = true
        self.endEditing(false)
    }
    
    @objc func handleAnswerButtonTap(_ button: UIButton) {
        guard currentModel != nil,
            let arrangedIndex = answersStackView.arrangedSubviews.firstIndex(of: button) else { return }
        onAnswerSelection?(&currentModel!, arrangedIndex)
    }
    
    @IBAction func handleAddNoteButtonTap(_ sender: Any) {
        guard currentModel != nil else { return }
        onAddNote?(&currentModel!)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        guard let textView = textView as? TextView, shouldChangeText else {
            return true
        }
        textView.onTextChanged?()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textView = textView as? TextView, let numberOfCharacters = textView.numberOfCharacters else {
            return true
        }
        return textView.text.count + (text.count - range.length) <= numberOfCharacters
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
