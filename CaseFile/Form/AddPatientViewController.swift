//
//  AddPatientViewController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 15/06/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class AddPatientViewController: MVViewController, UITableViewDelegate, UITableViewDataSource, FormDropdownCellDelegate {
    
    let model: PatientViewModel
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var proceedButton: ActionButton!
    
    private let dropdownCellIdentifier = "FormDropdownCell"
    private let textCellIdentifier = "FormTextCell"
    
    // MARK: - Object
    
    init(withModel model: PatientViewModel) {
        self.model = model
        super.init(nibName: "AddPatientViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - VC
    override func viewDidLoad() {
        super.viewDidLoad()
        switch model.operation {
        case .add:
            navigationItem.title = "Title.Patients.Add".localized
        case .edit:
            navigationItem.title = "Title.Patients.Edit".localized
        case .view:
            break
        }
        view.backgroundColor = .cn_gray2
        bindToModelUpdates()
        configureTableView()
        configureButton()
        updateInterface()
    }
    
    fileprivate func bindToModelUpdates() {
        model.onStateChanged = { [weak self] in
            self?.updateInterface()
        }
        model.onSaveStateChanged = { [weak self] in
            self?.updateInterface()
        }
    }
    
    func configureTableView() {
        tableView.backgroundColor = .cn_gray2
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: dropdownCellIdentifier, bundle: nil), forCellReuseIdentifier: dropdownCellIdentifier)
        tableView.register(UINib(nibName: textCellIdentifier, bundle: nil), forCellReuseIdentifier: textCellIdentifier)
    }
    
    func configureButton() {
        proceedButton.setTitle("Button_Continue".localized, for: .normal)
        proceedButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8).isActive = true
        proceedButton.addTarget(self, action: #selector(proceedButtonTouched(sender:)), for: .touchUpInside)
    }
    
    func updateInterface() {
        tableView.reloadData()
        proceedButton.isEnabled = model.canContinue
    }
    
    @objc func proceedButtonTouched(sender: Any) {
        model.processForm()
        AppRouter.shared.goToFormsSelection(beneficiary: model.beneficiary, from: self)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.generalDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let source = model.generalDataSource[indexPath.row]
        var cell: UITableViewCell?
        switch source.fieldType {
        case .name:
            cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
            if cell == nil {
                cell = FormTextCell(style: .default, reuseIdentifier: textCellIdentifier)
            }
            if let cell = cell as? FormTextCell {
                cell.label.text = source.text
                cell.textField.placeholder = source.placeholder
                cell.textField.text = source.description
                cell.textField.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
            }
        case .birthDate:
            fallthrough
        case .civilStatus:
            fallthrough
        case .city:
            fallthrough
        case .county:
            fallthrough
        case .gender:
            fallthrough
        case .relationship:
            cell = tableView.dequeueReusableCell(withIdentifier: dropdownCellIdentifier, for: indexPath)
            if cell == nil {
                cell = FormDropdownCell(style: .default, reuseIdentifier: dropdownCellIdentifier)
            }
            if let cell = cell as? FormDropdownCell {
                cell.delegate = self
                cell.label.text = source.text
                cell.dropdown.placeholder = source.placeholder
                cell.dropdown.value = source.description
                cell.isLoading = source.isLoading
                cell.dropdown.isEnabled = !(source.fieldType == .city && model.countyForm.value == nil)
            }
        }
        cell?.backgroundColor = .clear
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    // MARK: - TextField events
    @objc func textChanged(sender: Any) {
        guard let textField = sender as? UITextField else {
            return
        }
        model.nameForm.value = textField.text
    }
    
    // MARK: - FormDropdownCellDelegate
    func didSelectDropdown(in cell: FormDropdownCell) {
        view.endEditing(true)
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let form = model.generalDataSource[indexPath.row]
        switch form.fieldType {
        case .birthDate:
            handleBirthdayPickerTapped(form: form)
        case .civilStatus:
            handleCivilStatusPickerTapped(form: form)
        case .county:
            handleCountyPickerTapped(form: form)
        case .city:
            handleCityPickerTapped(form: form)
        case .gender:
            handleGenderPickerTapped(form: form)
        default:
            break
        }
    }
    
    // Present birthday picker
    func handleBirthdayPickerTapped(form: PatientForm) {
        let pickerModel = TimePickerViewModel(withTime: form.value as? Date, dateFormatter: form.timeFormatter)
        pickerModel.maxDate = Date();
        let picker = TimePickerViewController(withModel: pickerModel)
        picker.onCompletion = { [weak self] value in
            if let value = value {
                form.value = value
                self?.updateInterface()
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    // Present civil status picker
    func handleCivilStatusPickerTapped(form: PatientForm) {
        form.getSource?() { [weak self] civilStatuses in
            guard let self = self, let source = civilStatuses as? [CivilStatus] else {
                return
            }
            let pickerOptions = source.compactMap {
                return GenericPickerValue(id: $0.rawValue, displayName: $0.description)
            }
            let pickerModel = GenericPickerViewModel(withValues: pickerOptions)
            if let selectedValue = form.value as? GenericPickerValue, let selectedValueIndex = selectedValue.id as? Int {
                pickerModel.selectedIndex = selectedValueIndex
            }
            let picker = GenericPickerViewController(withModel: pickerModel)
            picker.onCompletion = { [weak self] value in
                guard let self = self else {
                    return
                }
                if let value = value {
                    form.value = CivilStatus(rawValue: value.id as! Int)
                    self.updateInterface()
                }
                self.dismiss(animated: true, completion: nil)
            }
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // Present county picker
    func handleCountyPickerTapped(form: PatientForm) {
        // if counties source is not populated, update it
        form.getSource?() { [weak self] counties in
            guard let self = self, let source = counties as? [CountyResponse] else {
                return
            }
            // sort & filter counties
            let pickerOptions = source
                .sorted { $0.name < $1.name}
                .enumerated()
                .compactMap { GenericPickerValue(id: $0, displayName: $1.name) }
            
            // create picker & set selected value
            let pickerModel = GenericPickerViewModel(withValues: pickerOptions)
            if let selectedCounty = form.value as? CountyResponse,
                let selectedCountyIndex = source.firstIndex(where: { $0.id == selectedCounty.id }) {
                pickerModel.selectedIndex = selectedCountyIndex
            }
            let picker = GenericPickerViewController(withModel: pickerModel)
            picker.onCompletion = { [weak self] value in
                guard let self = self else {
                    return
                }
                if let selectedCounty = value {
                    form.value = source[selectedCounty.id as! Int]
                    self.model.cityForm.value = nil
                    self.updateInterface()
                }
                self.dismiss(animated: true, completion: nil)
            }
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // Present city picker
    func handleCityPickerTapped(form: PatientForm) {
        // check county to be selected
        guard model.countyForm.value != nil else {
            let alert = UIAlertController.error(withMessage: "Validation.CountyNotSelected".localized)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        form.getSource?() { [weak self] cities in
            guard let self = self, let source = cities as? [CityResponse] else {
                return
            }
            // sort & filter cities
            let pickerOptions = source
                .sorted { $0.name < $1.name}
                .enumerated()
                .compactMap { GenericPickerValue(id: $0, displayName: $1.name) }
            
            // create picker & set selected value
            let pickerModel = GenericPickerViewModel(withValues: pickerOptions)
            if let selectedCity = form.value as? CityResponse,
                let selectedCityIndex = source.firstIndex(where: { $0.id == selectedCity.id }) {
                pickerModel.selectedIndex = selectedCityIndex
            }
            let picker = GenericPickerViewController(withModel: pickerModel)
            picker.onCompletion = { [weak self] value in
                guard let self = self else {
                    return
                }
                if let selectedCity = value {
                    form.value = source[selectedCity.id as! Int]
                    self.updateInterface()
                }
                self.dismiss(animated: true, completion: nil)
            }
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // Present gender picker
    func handleGenderPickerTapped(form: PatientForm) {
        form.getSource?() { [weak self] genders in
            guard let self = self, let source = genders as? [Gender] else {
                return
            }
            let pickerOptions = source
                .enumerated()
                .compactMap {
                return GenericPickerValue(id: $0, displayName: $1.description)
            }
            let pickerModel = GenericPickerViewModel(withValues: pickerOptions)
            if let selectedGender = form.value as? Gender {
                pickerModel.selectedIndex = selectedGender.rawValue
            }
            let picker = GenericPickerViewController(withModel: pickerModel)
            picker.onCompletion = { [weak self] value in
                guard let self = self else {
                    return
                }
                if let value = value {
                    form.value = source[value.id as! Int]
                    self.updateInterface()
                }
                self.dismiss(animated: true, completion: nil)
            }
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    deinit {
        model.rollback()
        DebugLog("DEALLOC ADD PATIENT VIEW CONTROLLER")
    }
}
