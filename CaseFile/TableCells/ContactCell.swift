//
//  ContactCell.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 25/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    static let reuseIdentifier = "ContactCell"
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var contact: Contact? {
        didSet {
            nameLabel.text = contact?.name
            phoneLabel.text = contact?.phone
            emailLabel.text = contact?.email
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    func setupCell() {
        
        // add shadow
        container.layer.shadowColor = UIColor.cardShadow.cgColor
        container.layer.shadowRadius = Configuration.shadowRadius
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = .zero
        
        //set label titles
        phoneTitleLabel.text = "Contacts.Phone".localized.uppercased()
        emailTitleLabel.text = "Contacts.Email".localized.uppercased()
    
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
