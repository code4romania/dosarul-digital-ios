//
//  Math.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 13/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import Foundation

extension Int {
    init?(_ from: Int16?) {
        guard let from = from else {
            return nil
        }
        self = Int(from)
    }
}
