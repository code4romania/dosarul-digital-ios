//
//  ActionButton.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum ActionButtonType {
    case light
    case heavy
}

@IBDesignable
class ActionButton: UIButton {
    
    var type: ActionButtonType = .heavy {
        didSet {
            setup()
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    fileprivate func setup() {
        switch type {
        case .heavy:
            setBackgroundImage(UIImage.from(color: .actionButtonBackground), for: .normal)
            setBackgroundImage(UIImage.from(color: .actionButtonBackgroundHighlighted), for: .highlighted)
            setBackgroundImage(UIImage.from(color: .actionButtonBackgroundDisabled), for: .disabled)

            setTitleColor(.actionButtonForeground, for: .normal)
            setTitleColor(.actionButtonForeground, for: .highlighted)
            setTitleColor(.actionButtonForegroundDisabled, for: .disabled)
        case .light:
            setBackgroundImage(UIImage.from(color: .actionButtonLightBackground), for: .normal)
            setBackgroundImage(UIImage.from(color: .actionButtonLightBackgroundHighlighted), for: .highlighted)
            setBackgroundImage(UIImage.from(color: .actionButtonLightBackgroundDisabled), for: .disabled)

            setTitleColor(.actionButtonLightForeground, for: .normal)
            setTitleColor(.actionButtonLightForeground, for: .highlighted)
            setTitleColor(.actionButtonLightForegroundDisabled, for: .disabled)
        }
        
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
