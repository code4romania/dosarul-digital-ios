//
//  ActionButton.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

@IBDesignable
class ActionButton: UIButton {
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    fileprivate func setup() {
        setBackgroundImage(UIImage.from(color: .actionButtonBackground), for: .normal)
        setBackgroundImage(UIImage.from(color: .actionButtonBackgroundHighlighted), for: .highlighted)
        setBackgroundImage(UIImage.from(color: .actionButtonBackgroundDisabled), for: .disabled)

        setTitleColor(.actionButtonForeground, for: .normal)
        setTitleColor(.actionButtonForeground, for: .highlighted)
        setTitleColor(.actionButtonForegroundDisabled, for: .disabled)
        
        if (imageView?.image != nil) {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        }

        tintColor = .clear
        
        layer.masksToBounds = true
        layer.cornerRadius = Configuration.buttonCornerRadius
    
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }

}
