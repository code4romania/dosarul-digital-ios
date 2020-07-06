//
//  BeneficiaryCell.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 02/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

protocol BeneficiaryCellDelegate: NSObject {
    func didTapBottomButton(in cell: BeneficiaryCell)
    func didTapLeftBottomButton(in cell: BeneficiaryCell)
    func didTapRightBottomButton(in cell: BeneficiaryCell)
    func didTapTopRightButton(in cell: BeneficiaryCell)
}

extension BeneficiaryCellDelegate {
    func didTapBottomButton(in cell: BeneficiaryCell) { }
    func didTapLeftBottomButton(in cell: BeneficiaryCell) { }
    func didTapRightBottomButton(in cell: BeneficiaryCell) { }
    func didTapTopRightButton(in cell: BeneficiaryCell) { }
}

enum BeneficiaryCellState {
    case summarized
    case detailed
}

class BeneficiaryCell: UITableViewCell {

    var state: BeneficiaryCellState = .summarized {
        didSet {
            setupCell()
        }
    }
    
    weak var delegate: BeneficiaryCellDelegate?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var ageTitleLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var civilStatusTitleLabel: UILabel!
    @IBOutlet weak var civilStatusLabel: UILabel!
    @IBOutlet weak var cityTitleLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countyTitleLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var bottomButton:ActionButton!
    @IBOutlet weak var bottomLeftButton:ActionButton!
    @IBOutlet weak var bottomRightButton:ActionButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell() {
        // add shadow
        container.layer.shadowColor = UIColor.cardShadow.cgColor
        container.layer.shadowRadius = Configuration.shadowRadius
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = .zero
        
        // hide/show views
        bottomButton.isHidden = state == .detailed
        arrowImageView.isHidden = state == .detailed
        editButton.isHidden = state == .summarized
        bottomLeftButton.isHidden = state == .summarized
        bottomRightButton.isHidden = state == .summarized
        
        // set button titles
        bottomButton.setTitle("Button_FillForm".localized, for: .normal)
        bottomLeftButton.setTitle("Button_Form".localized, for: .normal)
        bottomRightButton.setTitle("Button_SendFile".localized, for: .normal)
        editButton.setTitle("Button_Edit".localized, for: .normal)
        bottomButton.type = .light
        bottomLeftButton.type = .light
        bottomRightButton.type = .light
        
        //set label titles
        ageTitleLabel.text = "Patients.Summary.Age.Title".localized.uppercased()
        civilStatusTitleLabel.text = "Patients.Summary.CivilStatus.Title".localized.uppercased()
        cityTitleLabel.text = "Patients.Summary.City.Title".localized.uppercased()
        countyTitleLabel.text = "Patients.Summary.County.Title".localized.uppercased()
    }
    
    func updateWithModel(_ beneficiary: Beneficiary) {
        nameLabel.text = beneficiary.name
        ageLabel.text = String(beneficiary.age)
        cityLabel.text = beneficiary.city
        countyLabel.text = beneficiary.county
        if let gender = Gender(rawValue: Int(beneficiary.gender)) {
            civilStatusLabel.text = CivilStatus(rawValue: Int(beneficiary.civilStatus))?.description(gender: gender).lowercased()
        } else {
            civilStatusLabel.text = CivilStatus(rawValue: Int(beneficiary.civilStatus))?.description.lowercased()
        }
    }
    
    @IBAction func buttonTouched(sender: UIButton) {
        switch sender {
        case bottomButton:
            delegate?.didTapBottomButton(in: self)
        case bottomLeftButton:
            delegate?.didTapLeftBottomButton(in: self)
        case bottomRightButton:
            delegate?.didTapRightBottomButton(in: self)
        case editButton:
            delegate?.didTapTopRightButton(in: self)
        default:
            break
        }
    }
    
}
