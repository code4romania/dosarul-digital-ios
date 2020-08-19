//
//  AttachButton.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

@IBDesignable
class AttachButton: UIButton {

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    fileprivate func setup() {
        setBackgroundImage(UIImage.from(color: .attachButtonBackgroundNormal), for: .normal)
        setBackgroundImage(UIImage.from(color: .attachButtonBackgroundDisabled), for: .disabled)
        setBackgroundImage(UIImage.from(color: .attachButtonBackgroundHighlighted), for: .highlighted)

        setTitleColor(.attachButtonForegroundNormal, for: .normal)
        setTitleColor(.attachButtonForegroundDisabled, for: .disabled)
        setTitleColor(.attachButtonForegroundHighlighted, for: .highlighted)

        tintColor = .clear
        
        layer.masksToBounds = true
        layer.cornerRadius = Configuration.buttonCornerRadius
    
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }

}
