//
//  Formatters.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let noteCell: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()
    
    static let defaultDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
}

extension Date {
    var currentAge: Int {
        return (Calendar.current.dateComponents([.year], from: self, to: Date())).year!
    }
    
    func toString() -> String {
        return DateFormatter.defaultDateFormatter.string(from: self)
    }
    
    func toString(dateFormatter: DateFormatter) -> String {
        return dateFormatter.string(from: self)
    }
}
