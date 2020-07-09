//
//  FormDropdownCell.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 15/06/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

protocol FormDropdownCellDelegate: class {
    func didSelectDropdown(in cell: FormDropdownCell)
}

class FormDropdownCell: UITableViewCell {
    
    weak var delegate: FormDropdownCellDelegate?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dropdown: DropdownButton!
    
    var isLoading: Bool = false {
        didSet {
            dropdown.isLoading = isLoading
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonTapped(sender: Any) {
        delegate?.didSelectDropdown(in: self)
    }
    
}
