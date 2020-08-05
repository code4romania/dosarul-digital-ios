//  Created by Code4Romania

import Foundation
import UIKit

extension UIColor {
    
    static let navigationBarBackground = UIColor(hexCode: 0x3468EF)
    static let navigationBarTint = UIColor(hexCode: 0xFFFFFF)
    
    static let navigationDrawerBackground = UIColor(hexCode: 0x23278A)
    static let navigationDrawerForeground = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    
    // Important: We need to make these checks until we have the minimum deployment set to iOS 11

    static var appBackground = UIColor(hexCode: 0xE5E5E5)
    static var headerBackground = UIColor(hexCode: 0xFFFFFF)
    static var defaultTableHeaderText = UIColor(hexCode: 0x86868A)
    static var defaultText = UIColor(hexCode: 0x333E48)
    static var viewBackgroundPrimary = UIColor(hexCode: 0xFEFEFE)

    static var formNameText = UIColor.black

    static var chooserButtonBorder = UIColor(hexCode: 0x333E48).withAlphaComponent(0.3)
    static var chooserButtonBackground = UIColor.clear
    static var chooserButtonSelectedBackground = navigationBarBackground
    
    static var actionButtonBackground = UIColor(hexCode: 0x3468EF)
    static var actionButtonBackgroundHighlighted = UIColor(hexCode: 0x2258E3)
    static var actionButtonBackgroundDisabled = UIColor(hexCode: 0x3468EF).withAlphaComponent(0.2)
    static var actionButtonForeground = UIColor.white
    static var actionButtonForegroundDisabled = UIColor(hexCode: 0x3468EF)
    
    static var actionButtonLightBackground = UIColor(hexCode: 0xE6F0FC)
    static var actionButtonLightBackgroundHighlighted = UIColor(hexCode: 0xD7E9FF)
    static var actionButtonLightBackgroundDisabled = UIColor(hexCode: 0xE6F0FC).withAlphaComponent(0.2)
    static var actionButtonLightForeground = UIColor(hexCode: 0x3468EF)
    static var actionButtonLightForegroundDisabled = UIColor(hexCode: 0x3468EF)
    
    static var drawerButtonBackground = UIColor(hexCode: 0x23278A)
    static var drawerButtonBackgroundHighlighted = UIColor(white: 1, alpha: 0.1)
    static var drawerButtonForeground = UIColor.white
    static var drawerButtonForegroundHighlighted = UIColor(hexCode: 0x8CE4ED)

    static var attachButtonForegroundNormal = UIColor(hexCode: 0x8CE4ED)
    static var attachButtonForegroundDisabled = UIColor(hexCode: 0x8CE4ED).withAlphaComponent(0.5)
    static var attachButtonForegroundHighlighted = UIColor(hexCode: 0x6AE0EC)
    static var attachButtonBackgroundNormal = UIColor.clear
    static var attachButtonBackgroundDisabled = UIColor.clear
    static var attachButtonBackgroundHighlighted = UIColor(hexCode: 0x8CE4ED).withAlphaComponent(0.2)

    static var cardBackground = UIColor.white
    static var cardBackgroundSelected = chooserButtonSelectedBackground
    static var cardShadow = UIColor(hexCode: 0x043252).withAlphaComponent(0.18)
    static var cardDarkerShadow = UIColor.black.withAlphaComponent(0.12)
    static var tableSectionHeaderBg = UIColor(hexCode: 0xEEEDED)

    static var textViewContainerBorder = UIColor(hexCode: 0xDDDDDD)
    static var textViewContainerBg = UIColor(hexCode: 0xFCFCFC)
    
    static var cn_lightGray = UIColor(hexCode: 0x989898)
    static var cn_lightBlue = UIColor(hexCode: 0x3468EF)
    
    static var cn_gray1 = UIColor(hexCode: 0x777777)
    static var cn_gray2 = UIColor(hexCode: 0xF6F5F5)

    convenience init(hexCode: UInt32) {
        var alpha = hexCode >> 24 & 0xFF
        let red   = hexCode >> 16 & 0xFF
        let green = hexCode >> 8 & 0xFF
        let blue  = hexCode >> 0 & 0xFF
        if alpha == 0 {
            alpha = 0xFF
        }
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha:CGFloat(alpha) / 255.0)
    }
    
}
