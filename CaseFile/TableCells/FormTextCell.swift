//
//  FormTextCell.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 15/06/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class FormTextCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textFieldWrapper: UIView!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldWrapper.layer.masksToBounds = true
        textFieldWrapper.layer.cornerRadius = Configuration.buttonCornerRadius
        textFieldWrapper.layer.borderWidth = 1
        textFieldWrapper.layer.borderColor = UIColor.textViewContainerBorder.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
