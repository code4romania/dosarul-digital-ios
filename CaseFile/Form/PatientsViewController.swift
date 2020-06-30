//
//  PatientsViewController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 28/05/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PatientsViewController: MVViewController, EmptyDataSetSource, EmptyDataSetDelegate, UITableViewDataSource, UITableViewDelegate {

    let model = PatientsViewModel()
    let tableView = UITableView()
    let addNewPatientButton = ActionButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = model.navigationTitle
        
        configureTableView()
        configureButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DebugLog("Application data view model:\n\(ApplicationData.shared.objectRepository)")
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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
        let addNewPatientVC = AddPatientViewController(withModel: AddPatientViewModel(fromRelationship: false))
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
