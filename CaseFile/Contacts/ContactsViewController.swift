//
//  ViewController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 25/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class ContactsViewController: MVViewController, UITableViewDelegate, UITableViewDataSource {
    
    var model = ContactsViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Title.Contacts".localized
        
        tableView.register(UINib(nibName: "ContactCell", bundle: nil),
                           forCellReuseIdentifier: ContactCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.reuseIdentifier,
                                                       for: indexPath) as? ContactCell else { fatalError("Wrong cell type") }
        let contact = model.contacts[indexPath.row]
        cell.contact = contact
        return cell
    }
    
}
