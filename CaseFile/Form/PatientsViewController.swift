//
//  PatientsViewController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 28/05/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PatientsViewController: MVViewController, EmptyDataSetSource, EmptyDataSetDelegate, UITableViewDataSource, UITableViewDelegate, BeneficiaryCellDelegate {

    let model: PatientViewModel
    let tableView = UITableView()
    let addNewPatientButton = ActionButton()
    
    required init(model: PatientViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Title.Patients".localized
        configureTableView()
        configureButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        model.operation = .view
        DebugLog("Application data view model:\n\(ApplicationData.shared.objectRepository)")
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        tableView.backgroundColor = .appBackground
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: "BeneficiaryCell", bundle: nil), forCellReuseIdentifier: "BeneficiaryCell")
        
        tableView.estimatedRowHeight = 256
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 52, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -8)
    }
    
    func configureButton() {
        addNewPatientButton.setImage(UIImage(named: "button-add-patient"), for: .normal)
        addNewPatientButton.setTitle("Button_AddPatient".localized, for: .normal)
        addNewPatientButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addNewPatientButton)
        if #available(iOS 11.0, *) {
            addNewPatientButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            addNewPatientButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        }
        addNewPatientButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        addNewPatientButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        addNewPatientButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addNewPatientButton.addTarget(self, action: #selector(onTapNewPatient(sender:)), for: .touchUpInside)
    }
    
    @objc func onTapNewPatient(sender: Any) {
        model.beneficiary = nil
        model.resetForm()
        model.operation = .add
        let addNewPatientVC = AddPatientViewController(withModel: model)
        navigationController?.pushViewController(addNewPatientVC, animated: true)
    }
    
    // MARK: EmptyDataSetSource
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Patients.Empty.Title".localized, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.cn_gray1
        ])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Patients.Empty.Description".localized, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.cn_gray1
        ])
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "icon-empty-data")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -150
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.beneficiaryList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let beneficiary = model.beneficiaryList?[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: "BeneficiaryCell", for: indexPath) as? BeneficiaryCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.state = .summarized
        cell.updateWithModel(beneficiary)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.beneficiary = model.beneficiaryList?[indexPath.row]
        let beneficiaryDetailsVC = PatientDetailsViewController(viewModel: model)
        self.navigationController?.pushViewController(beneficiaryDetailsVC, animated: true)
    }
    
    func didTapBottomButton(in cell: BeneficiaryCell) {
        print("bottom")
    }
    
    func didTapLeftBottomButton(in cell: BeneficiaryCell) {
        print("left")
    }
    
    func didTapRightBottomButton(in cell: BeneficiaryCell) {
        print("right")
    }
    
}
