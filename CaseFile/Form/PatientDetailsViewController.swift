//
//  PatientDetailsViewController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 03/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PatientDetailsViewController: UIViewController, EmptyDataSetSource, EmptyDataSetDelegate, UITableViewDelegate, UITableViewDataSource, BeneficiaryCellDelegate {

    let model: PatientViewModel
    let tableView = UITableView()
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        model.operation = .view
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.emptyDataSetDelegate = self
//        tableView.emptyDataSetSource = self
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeneficiaryCell", for: indexPath) as? BeneficiaryCell,
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
        default:
            return UITableViewCell()
        }
        
    }
    
    func didTapLeftBottomButton(in cell: BeneficiaryCell) {
        AppRouter.shared.goToFormsFill(beneficiary: model.beneficiary, from: self)
    }
    
    func didTapRightBottomButton(in cell: BeneficiaryCell) {
        
    }
    
    func didTapTopRightButton(in cell: BeneficiaryCell) {
        model.resetForm()
        model.operation = .edit
        let addNewPatientVC = AddPatientViewController(withModel: model)
        navigationController?.pushViewController(addNewPatientVC, animated: true)
    }
    
}
