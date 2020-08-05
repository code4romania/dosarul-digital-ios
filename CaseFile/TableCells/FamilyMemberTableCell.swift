//
//  FamilyMemberTableCell.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 03/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class FamilyMemberTableCell: UITableViewCell {

    static let reuseIdentifier = "FamilyMemberTableCell"
    override var reuseIdentifier: String? { return type(of: self).reuseIdentifier }
    
    @IBOutlet weak var outerContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView(frame: .zero)
        selectedBackgroundView?.backgroundColor = .clear
        selectionStyle = .none
        outerContainer.backgroundColor = .clear
        outerContainer.layer.shadowColor = UIColor.cardShadow.cgColor
        outerContainer.layer.shadowOffset = .zero
        outerContainer.layer.shadowRadius = Configuration.shadowRadius
        outerContainer.layer.shadowOpacity = Configuration.shadowOpacity
        cardContainer.layer.cornerRadius = Configuration.buttonCornerRadius
        cardContainer.layer.masksToBounds = true
        detailsLabel.textColor = .defaultText
        cardContainer.backgroundColor = .cardBackground
    }
    
    var beneficiary: Beneficiary? {
        didSet {
            detailsLabel.text = beneficiary?.name
            layoutIfNeeded()
        }
    }
    
}
