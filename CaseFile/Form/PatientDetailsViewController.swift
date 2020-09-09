//
//  PatientDetailsViewController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 03/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class PatientDetailsViewController: MVViewController, UITableViewDelegate, UITableViewDataSource, BeneficiaryCellDelegate, GenericTableHeaderDelegate {

    let model: PatientViewModel
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    var familyMembersHeaderView: GenericTableHeader?
    var notesHeaderView: GenericTableHeader?
    var formHistoryHeaderView: GenericTableHeader?
    
    required init(viewModel: PatientViewModel) {
        self.model = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Title.Patients.Details".localized
        configureTableView()
        configureNotes()
        bindToModelUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        model.operation = .view
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .appBackground
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: "BeneficiaryCell", bundle: nil),
                           forCellReuseIdentifier: "BeneficiaryCell")
        tableView.register(UINib(nibName: "NoteHistoryTableCell", bundle: nil),
                           forCellReuseIdentifier: NoteHistoryTableCell.reuseIdentifier)
        tableView.register(UINib(nibName: "FormSummaryTableCell", bundle: nil),
                           forCellReuseIdentifier: FormSummaryTableCell.reuseIdentifier)
        tableView.register(UINib(nibName: "FamilyMemberTableCell", bundle: nil),
                           forCellReuseIdentifier: FamilyMemberTableCell.reuseIdentifier)
        
        tableView.estimatedRowHeight = 256
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 52, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -8)
    }
    
    func configureNotes() {
        self.model.notesModel = NoteViewModel(for: self.model.beneficiary, with: nil)
        self.model.notesModel?.onUpdate = { [weak self] in
            self?.model.notesModel?.load()
            self?.tableView.reloadData()
        }
    }
    
    func bindToModelUpdates() {
        model.onFormFilled = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        // Beneficiaries, family members, history, notes
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        // Beneficiary
        case 0:
            return 1
        // Family members
        case 1:
            return model.beneficiary?.familyMembers?.count ?? 0
        // History
        case 2:
            return model.filledForms?.count ?? 0
        // Notes
        case 3:
            return model.notesModel!.notes.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeneficiaryCell",
                                                           for: indexPath) as? BeneficiaryCell,
                let beneficiary = model.beneficiary else {
                    return UITableViewCell()
            }
            cell.beneficiary = beneficiary
            cell.delegate = self
            cell.state = .detailed
            cell.updateInterface()
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyMemberTableCell",
                                                           for: indexPath) as? FamilyMemberTableCell,
                let familyMembers = model.beneficiary?.familyMembers?.allObjects as? [Beneficiary],
                familyMembers.count > indexPath.row else {
                    return UITableViewCell()
            }
            cell.beneficiary = familyMembers[indexPath.row]
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FormSummaryTableCell",
                                                           for: indexPath) as? FormSummaryTableCell,
                let filledForms = model.filledForms,
                filledForms.count > indexPath.row else {
                    return UITableViewCell()
            }
            cell.update(with: filledForms[indexPath.row])
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteHistoryTableCell.reuseIdentifier,
                                                           for: indexPath) as? NoteHistoryTableCell else {
                                                            return UITableViewCell()
            }
            let cellModel = model.notesModel!.notes[indexPath.row]
            cell.update(withModel: cellModel)
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        // Beneficiary
        case 0:
            return nil
        // Family members
        case 1:
            return viewForFamilyMembers()
        // History
        case 2:
            return viewForFormHistory()
        // Notes
        case 3:
            return viewForNotes()
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    func viewForFamilyMembers() -> UIView? {
        familyMembersHeaderView = GenericTableHeader(title: "FamilyMembers.Title".localized,
                                        buttonTitle: "FamilyMembers.Button.AddMembers".localized,
                                        emptyImage: nil,
                                        emptyTitle: model.beneficiary?.familyMembers?.count == 0 ?  "FamilyMembers.Empty.Title".localized : nil,
                                        emptyDescription: model.beneficiary?.familyMembers?.count == 0 ? "FamilyMembers.Empty.Description".localized : nil)
        familyMembersHeaderView?.delegate = self
        return familyMembersHeaderView
    }
    
    func viewForFormHistory() -> UIView? {
        formHistoryHeaderView = GenericTableHeader(title: "FormHistory.Title".localized,
                                                   buttonTitle: nil,
                                                   emptyImage: model.filledForms?.count == 0 ?
                                                    UIImage(named: "icon-empty-form-history") : nil,
                                                   emptyTitle: model.filledForms?.count == 0 ?
                                                    "FormHistory.Empty.Title".localized : nil,
                                                   emptyDescription: model.filledForms?.count == 0 ? "FormHistory.Empty.Description".localized : nil)
        formHistoryHeaderView?.delegate = self
        return formHistoryHeaderView
    }
    
    func viewForNotes() -> UIView? {
        notesHeaderView = GenericTableHeader(title: "Notes.Title".localized,
                                        buttonTitle: "Notes.Button.AddNote".localized,
                                        emptyImage: nil,
                                        emptyTitle: model.notesModel?.notes.count == 0 ? "Notes.Empty.Title".localized : nil,
                                        emptyDescription: model.notesModel?.notes.count == 0 ? "Notes.Empty.Description".localized : nil)
        notesHeaderView?.delegate = self
        return notesHeaderView
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            // Family members
            guard let familyMembers = model.beneficiary?.familyMembers?.allObjects as? [Beneficiary],
                familyMembers.count > indexPath.row else {
                    return
            }
            model.beneficiary = familyMembers[indexPath.row]
            let beneficiaryDetailsVC = PatientDetailsViewController(viewModel: model)
            self.navigationController?.pushViewController(beneficiaryDetailsVC, animated: true)
            self.navigationController?.viewControllers.removeAll(where: { $0 == self })
        case 2:
            // Forms
            guard let filledForms = model.filledForms,
                filledForms.count > indexPath.row else {
                let message = "Error: can't load question list model for form"
                let alert = UIAlertController.error(withMessage: message)
                present(alert, animated: true, completion: nil)
                return
            }
            AppRouter.shared.goToFormDate(withId: filledForms[indexPath.row].formId,
                                          for: model.beneficiary,
                                          from: self)
            break
        default:
            break
        }
    }
    
    // MARK: BeneficiaryCellDelegate
    func didTapLeftBottomButton(in cell: BeneficiaryCell) {
        AppRouter.shared.goToFormsFill(beneficiary: model.beneficiary, from: self)
    }
    
    func didTapRightBottomButton(in cell: BeneficiaryCell) {
        // send form
        cell.bottomRightButton.isEnabled = false
        guard let beneficiaryId = cell.beneficiary?.id else {
            return
        }
        AppDelegate.dataSourceManager.sendForm(beneficiaryId: Int(beneficiaryId)) { (success, error) in
            cell.bottomRightButton.isEnabled = true
            if error != nil || success == false {
                let alert = UIAlertController.error(withMessage: "Error.SendFileFailed".localized)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController.info(withMessage: "AlertMessage_FormSent".localized)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func didTapTopRightButton(in cell: BeneficiaryCell) {
        model.resetForm()
        model.operation = .edit
        let addNewPatientVC = AddPatientViewController(withModel: model)
        navigationController?.pushViewController(addNewPatientVC, animated: true)
    }
    
    // MARK: GenericTableHeaderDelegate
    func genericTableHeader(_ tableHeader: GenericTableHeader, didTap button: UIButton) {
        switch tableHeader {
        case familyMembersHeaderView:
            guard let beneficiary = model.beneficiary else {
                return
            }
            let addFamilyMemberModel = PatientViewModel(operation: .add)
            addFamilyMemberModel.isFamilyOfBeneficiary = beneficiary
            addFamilyMemberModel.shouldOverrideHeaderContent = false
            let addFamilyMemberVC = AddPatientViewController(withModel: addFamilyMemberModel)
            navigationController?.pushViewController(addFamilyMemberVC, animated: true)
        case formHistoryHeaderView:
            break
        case notesHeaderView:
            AppRouter.shared.openAddNote(noteModel: self.model.notesModel)
            break
        default:
            break
        }
    }
}
