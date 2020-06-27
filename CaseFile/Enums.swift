//
//  Enums.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 26/06/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import Foundation

enum CivilStatus: Int, CustomStringConvertible {
    case notMarried
    case married
    case divorced
    case widowed
    
    var description: String {
        switch self {
        case .notMarried:
            return "Enums.CivilStatus.NotMarried".localized
        case .married:
            return "Enums.CivilStatus.Married".localized
        case .divorced:
            return "Enums.CivilStatus.Divorced".localized
        case .widowed:
            return "Enums.CivilStatus.Widowed".localized
        }
    }
}

enum Gender: Int, CustomStringConvertible {
    case male
    case female
    
    var description: String {
        switch self {
        case .female:
            return "Enums.Gender.Female".localized
        case .male:
            return "Enums.Gender.Male".localized
        }
    }
}
