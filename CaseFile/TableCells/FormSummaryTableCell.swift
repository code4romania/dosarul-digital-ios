//
//  FormSummaryTableCell.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 06/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

struct FormSummaryCellModel {
    var synced: Bool
    var fillDate: Date?
    var name: String?
    var formId: Int
}

class FormSummaryTableCell: UITableViewCell {
    
    static let reuseIdentifier = "FormSummaryTableCell"
    override var reuseIdentifier: String? { return type(of: self).reuseIdentifier }
    
    @IBOutlet weak var outerContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var syncImageView: UIImageView!
    
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
        dateLabel.textColor = .defaultText
        cardContainer.backgroundColor = .cardBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with model: FormSummaryCellModel) {
        detailsLabel.text = model.name
        dateLabel.text = model.fillDate?.toString()
        layoutIfNeeded()
    }
    
}
