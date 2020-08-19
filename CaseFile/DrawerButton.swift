//
//  DrawerButton.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 28/05/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class DrawerButton: UIButton {
    
    private var normalFont: UIFont?
    private var highlightedFont: UIFont?
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                tintColor = .drawerButtonForegroundHighlighted
            } else {
                tintColor = .drawerButtonForeground
            }
        }
    }
    
    func setup() {
        setBackgroundImage(UIImage.from(color: .drawerButtonBackground), for: .normal)
        setBackgroundImage(UIImage.from(color: .drawerButtonBackgroundHighlighted), for: .highlighted)
        
        setTitleColor(.drawerButtonForeground, for: .normal)
        setTitleColor(.drawerButtonForegroundHighlighted, for: .highlighted)
        
        layer.masksToBounds = true
        layer.cornerRadius = Configuration.buttonCornerRadius
        
        contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        
        switch state {
        case .normal:
            titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        case .highlighted:
            titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        default:
            break
        }
    }
    
    func set(font: UIFont, for state:State) {
        switch state {
        case .normal:
            normalFont = font
        case .highlighted:
            highlightedFont = font
        default:
            break
        }
    }
}
