//
//  FormDateViewController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 05/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class FormDateViewController: MVViewController {

    var model: FormDateViewModel
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateButton: DropdownButton!
    @IBOutlet weak var proceedButton: ActionButton!
    
    init(withModel model: FormDateViewModel) {
        self.model = model
        super.init(nibName: "FormDateViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindToModelUpdates()
    }
    
    fileprivate func configureAppearance() {
        title = model.title
        
        dateLabel.text = "Label_Form_Fill_Date".localized
        
        dateButton.placeholder = "Select".localized
        dateButton.addTarget(self, action: #selector(dateButtonTouched(sender:)), for: .touchUpInside)
        
        proceedButton.setTitle("Next".localized, for: .normal)
        proceedButton.addTarget(self, action: #selector(proceedButtonTouched(sender:)), for: .touchUpInside)
    }
    
    fileprivate func bindToModelUpdates() {
        model.onUpdate = { [weak self] in
            self?.updateInterface()
        }
    }
    
    fileprivate func updateInterface() {
        guard let selectedDate = model.date else { return }
        dateButton.value = selectedDate.toString()
    }
    
    @objc func dateButtonTouched(sender: Any) {
        let pickerModel = TimePickerViewModel(withTime: model.date, dateFormatter: DateFormatter.defaultDateFormatter)
        pickerModel.maxDate = Date();
        let picker = TimePickerViewController(withModel: pickerModel)
        picker.onCompletion = { [weak self] value in
            if let value = value {
                self?.model.date = value
                self?.updateInterface()
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @objc func proceedButtonTouched(sender: Any) {
        guard let questionsModel = QuestionListViewModel(withFormUsingCode: model.code) else {
            let message = "Error: can't load question list model for form with code \(model.code)"
            let alert = UIAlertController.error(withMessage: message)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let questionsVC = QuestionListViewController(withModel: questionsModel)
        navigationController?.pushViewController(questionsVC, animated: true)
        AppRouter.shared.resetDetailsPane()
    }

}
