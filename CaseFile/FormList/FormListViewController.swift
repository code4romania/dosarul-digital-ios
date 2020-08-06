//
//  FormSetsViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 22/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class FormListViewController: MVViewController {
    
    var model: FormListViewModel
    
    @IBOutlet weak var syncingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var syncDetailsLabel: UILabel!
    @IBOutlet weak var syncButton: ActionButton!
    @IBOutlet weak var syncContainerHeightZero: NSLayoutConstraint!
    @IBOutlet weak var syncContainer: UIView!
    @IBOutlet weak var proceedButton: ActionButton!
    @IBOutlet weak var retryButton: ActionButton!
    @IBOutlet weak var downloadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewBottomToSyncViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomToProceedButtonConstraint: NSLayoutConstraint!
    
    // MARK: - Object
    
    init(withModel model: FormListViewModel) {
        self.model = model
        super.init(nibName: "FormListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch model.selectionAction {
        case .fillForm:
            title = "Title.FormSetsFill".localized
            tableView.allowsMultipleSelection = false
        case .selectForm:
            title = "Title.FormSetsSelect".localized
            tableView.allowsMultipleSelection = true
        }
        configureSubviews()
        updateLabelsTexts()
        updateInterface()
        bindToUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.reload()
        updateInterface()
        DispatchQueue.main.async {
            switch self.model.selectionAction {
            case .fillForm:
                self.configureSyncContainer()
            case .selectForm:
                self.configureProceedButton()
            }
            if self.model.forms.isEmpty {
                // only show the spinner and hide the table view if there are no forms
                self.tableView.isHidden = true
                self.downloadingSpinner.startAnimating()
            }
            self.retryButton.isHidden = true
            self.model.downloadFreshData()
        }
    }
    
    // MARK: - Config
    
    fileprivate func bindToUpdates() {
        model.onDownloadComplete = { [weak self] error in
            guard let self = self else { return }
            self.downloadingSpinner.stopAnimating()
            if self.model.forms.isEmpty {
                // only treat this as a failure if we have no forms yet.
                // otherwise, leave the older versions
                if let _ = error {
                    let alert = UIAlertController(title: "Error".localized,
                                                  message: "Error.DataDownloadFailed".localized,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.retryButton.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    self.updateInterface()
                }
            } else {
                self.tableView.isHidden = false
                self.retryButton.isHidden = true
                self.updateInterface()
            }
        }
        model.onDownloadingStateChanged = { [weak self] in
            guard let self = self else { return }
            self.model.isDownloadingData ? self.downloadingSpinner.startAnimating() : self.downloadingSpinner.stopAnimating()
            self.tableView.alpha = self.model.isDownloadingData ? 0.3 : 1
            self.tableView.isUserInteractionEnabled = !self.model.isDownloadingData
            self.syncContainer.alpha = self.model.isDownloadingData ? 0 : 1
        }
        model.onSyncingStateChanged = { [weak self] in
            guard let self = self else { return }
            self.model.isSynchronising ? self.syncingSpinner.startAnimating() : self.syncingSpinner.stopAnimating()
            self.tableView.alpha = self.model.isSynchronising ? 0.3 : 1
        }
        model.onSelectionStateChanged = { [weak self] in
            guard let self = self else { return }
            self.proceedButton.isEnabled = self.model.selectedForms.count > 0
        }
        model.onLoadingChanged = { [weak self] (loading, error) in
            if loading {
                self?.showFullScreenLoading(text: (self?.model.beneficiary?.id ?? -1) == -1 ? "Loading.Title.AddPatient".localized : "Loading.Title.EditPatient".localized)
            } else {
                self?.hideFullScreenLoading(text: error == nil ? "Loading.Success.AddPatient".localized : "Loading.Error.AddPatient".localized,
                                            error: error != nil)
            }
        }
    }

    fileprivate func configureSubviews() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        
        switch model.selectionAction {
        case .fillForm:
            break
        case .selectForm:
            tableView.tableHeaderView = {
                let header = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.self.width, height: 104))
                header.backgroundColor = .clear
                header.textColor = UIColor.cn_gray1
                header.font = UIFont.systemFont(ofSize: 14)
                header.textAlignment = .center
                header.numberOfLines = 0
                header.text = "Instructions.Form.Select".localized
                return header
            }()
        }
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "FormSetTableCell", bundle: nil),
                           forCellReuseIdentifier: FormSetTableCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        retryButton.isHidden = true
    }
    
    fileprivate func configureSyncContainer() {
        proceedButton.isHidden = true
        let needsSync = DB.shared.needsSync
        tableViewBottomToSyncViewConstraint.isActive = true
        setSyncContainer(hidden: !needsSync)
    }
    
    fileprivate func configureProceedButton() {
        tableViewBottomToProceedButtonConstraint.isActive = true
        proceedButton.setTitle("Button_Continue".localized, for: .normal)
        proceedButton.addTarget(self, action: #selector(proceedButtonTouched(sender:)), for: .touchUpInside)
    }
    
    @objc func proceedButtonTouched(sender: Any) {
        model.setLoading(true, error: nil)
        ApplicationData.shared.setObject(model.selectedForms as NSObject, for: .patientForms)
        ApplicationData.shared.setObject(model.addedForms as NSObject, for: .patientAddedForms)
        ApplicationData.shared.setObject(model.removedForms as NSObject, for: .patientRemovedForms)
        PatientViewModel.createBeneficiary { (beneficiaryId, error) in
            self.model.setLoading(false, error: error)
            guard error == nil else {
                return
            }
            try! CoreData.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AppRouter.shared.goToDashboard()
            }
        }
    }

    // MARK: - UI
    
    fileprivate func updateInterface() {
        tableView.reloadData()
        proceedButton.isEnabled = model.selectedForms.count > 0
    }
    
    fileprivate func updateLabelsTexts() {
        syncDetailsLabel.text = "Info.DataNotSyncronised".localized
        syncButton.setTitle("Button_SyncData".localized, for: .normal)
        retryButton.setTitle("Button_Retry".localized, for: .normal)
    }
    
    fileprivate func setSyncContainer(hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.setSyncContainer(hidden: hidden)
        }
    }

    fileprivate func setSyncContainer(hidden: Bool) {
        syncContainerHeightZero.isActive = hidden
        view.layoutIfNeeded()
    }

    // MARK: - Logic
    
    // MARK: - Actions
    
    @IBAction func handleRetryButtonAction(_ sender: Any) {
        retryButton.isHidden = true
        downloadingSpinner.startAnimating()
        tableView.isHidden = true
        model.downloadFreshData()
    }
    
    @IBAction func handleSyncButtonAction(_ sender: Any) {
        MVAnalytics.shared.log(event: .tapManualSync)
        setSyncContainer(hidden: true, animated: true)
        RemoteSyncer.shared.syncUnsyncedData { error in
            if let error = error {
                let alert = UIAlertController.error(withMessage: error.localizedDescription)
                self.present(alert, animated: true) {
                    self.setSyncContainer(hidden: false, animated: true)
                }
            }
        }
    }
    
    fileprivate func continueToFillDate() {
        
    }
    
    fileprivate func continueToForm(withCode code: String) {
        guard let formDateModel = FormDateViewModel(withFormUsingCode: code) else {
            let message = "Error: can't load question list model for form with code \(code)"
            let alert = UIAlertController.error(withMessage: message)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let formDateVC = FormDateViewController(withModel: formDateModel)
        navigationController?.pushViewController(formDateVC, animated: true)
    }
    
    fileprivate func continueToNote() {
        #warning("check this when it hits breakpoint")
        AppRouter.shared.openAddNote()
    }
    
    deinit {
        ApplicationData.shared.removeObject(for: .patientForms)
        ApplicationData.shared.removeObject(for: .patientAddedForms)
        ApplicationData.shared.removeObject(for: .patientRemovedForms)
        DebugLog("DEALLOC FORMS LIST VIEW CONTROLLER")
    }
}

// MARK: - Table View Data Source + Delegate

extension FormListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch model.selectionAction {
        case .fillForm:
            return 1// return 2 - removed note
        case .selectForm:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return model.forms.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormSetTableCell.reuseIdentifier,
                                                       for: indexPath) as? FormSetTableCell else { fatalError("Wrong cell type") }
        switch indexPath.section {
        case 0:
            let cellModel = model.forms[indexPath.row]
            cell.update(withModel: cellModel)
        default:
            // note cell
            cell.updateAsNote()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch model.selectionAction {
        case .fillForm:
            return 16
        case .selectForm:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: .zero)
        header.backgroundColor = .clear
        return header
    }
}

extension FormListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.selectionAction {
        case .fillForm:
            switch indexPath.section {
            case 0:
                // form was tapped
                let formSet = model.forms[indexPath.row]
                continueToForm(withCode: formSet.code)
            default:
                // add note was tapped
                continueToNote()
            }
        case .selectForm:
            let formSet = model.forms[indexPath.row]
            // form selected
            if model.selectedForms.contains(formSet) {
                // remove from selected forms
                model.selectedForms = model.selectedForms.filter { $0 != formSet }
                if model.originalForms.contains(formSet) {
                    model.removedForms.append(formSet)
                }
                model.addedForms.removeAll { $0 == formSet }
            } else {
                // add to selected forms
                model.selectedForms.append(formSet)
                if !model.originalForms.contains(formSet) {
                    model.addedForms.append(formSet)
                }
                model.removedForms.removeAll { $0 == formSet }
            }
            print("ADDED FORMS: \(model.addedForms.map({$0.id}))")
            print("REMOVED FORMS: \(model.removedForms.map({$0.id}))")
            tableView.reloadRows(at: [indexPath], with: .none)
        }   
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard model.selectionAction == .selectForm else {
            return
        }
        let formSet = model.forms[indexPath.row]
        if model.selectedForms.contains(formSet) {
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}
