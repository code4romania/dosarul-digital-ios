//
//  TextView.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 18/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class TextView: UITextView {
    
    var numberOfCharacters: Int?
    
    var onTextChanged: (() -> ())?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
