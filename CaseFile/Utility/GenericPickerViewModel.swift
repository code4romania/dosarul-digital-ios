//
//  GenericPickerViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation

struct GenericPickerValue: CustomStringConvertible {
    var id: Any
    var displayName: String
    
    var description: String {
        return displayName
    }
}

class GenericPickerViewModel: NSObject {
    var values: [GenericPickerValue]
    
    var selectedValue: GenericPickerValue? {
        return selectedIndex < values.count ? values[selectedIndex] : nil
    }
    
    var selectedIndex: Int = 0
    
    init(withValues values: [GenericPickerValue]) {
        self.values = values
        super.init()
    }
}
