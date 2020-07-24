//
//  FormSetTableCell.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 22/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

/// Represents a Form Set to be displayed using the table cell
struct FormSetCellModel: Equatable {
    var id: Int
    var icon: UIImage
    var title: String
    var code: String
    var progress: CGFloat
    var answeredOutOfTotalQuestions: String
    var selected: Bool?
    var selectionType: FormSelectionType
    
    static func == (lhs: FormSetCellModel, rhs: FormSetCellModel) -> Bool {
        return lhs.id == rhs.id
    }
}

class FormSetTableCell: UITableViewCell {
    
    static let reuseIdentifier = "FormSetTableCell"

    @IBOutlet weak var outerCardContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var selectionView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var answeredLabel: UILabel!
    
    @IBOutlet weak var progressContainer: UIView!
    
    var selectionType: FormSelectionType?
    
    // set this one's multiplier to the actual progress
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        outerCardContainer.layer.shadowColor = UIColor.cardShadow.cgColor
        outerCardContainer.layer.shadowRadius = Configuration.shadowRadius
        outerCardContainer.layer.shadowOpacity = Configuration.shadowOpacity
        selectedBackgroundView = UIView(frame: .zero)
        selectedBackgroundView?.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        updateSelectionState(selected: selected)
    }
    
    fileprivate func updateSelectionState(selected: Bool) {
        switch selectionType {
        case .fillForm:
            cardContainer.backgroundColor = selected ?
                UIColor.cardBackgroundSelected : UIColor.cardBackground
            selectionView.isHidden = true
        case .selectForm:
            selectionView.isHidden = !selected
        case .none:
            break
        }
    }
    
    func update(withModel model: FormSetCellModel) {
        titleLabel.attributedText = titleText(ofModel: model)
        progressWidthConstraint.constant = model.selectionType == .fillForm ? model.progress * cardContainer.frame.size.width : 0
        answeredLabel.text = model.answeredOutOfTotalQuestions
        answeredLabel.isHidden = model.selectionType == .selectForm
        progressContainer.isHidden = model.progress == 0
        outerCardContainer.layoutIfNeeded()
        selectionType = model.selectionType
    }
    
    func titleText(ofModel model: FormSetCellModel) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        
        let text = NSMutableAttributedString(string: model.title,
                                             attributes: [
                                                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                                                .foregroundColor: UIColor.formNameText,
                                                .paragraphStyle: paragraphStyle
                                             ])
        
        let codeText = " (\(model.code.uppercased()))"
        text.append(NSAttributedString(string: codeText,
                                       attributes: [
                                        .font: UIFont.systemFont(ofSize: 18, weight: .regular),
                                        .foregroundColor: UIColor.formNameText.withAlphaComponent(0.4),
                                        .paragraphStyle: paragraphStyle
                                       ]))
        
        return text
    }
    
    func updateAsNote() {
        titleLabel.text = "Label_AddNote".localized
        titleLabel.textColor = .formNameText
        answeredLabel.text = nil
        progressContainer.isHidden = true
        outerCardContainer.layoutIfNeeded()
    }
    
}
