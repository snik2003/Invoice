//
//  Date+Extension.swift
//  Invoice
//
//  Created by Сергей Никитин on 02.12.2022.
//

import Foundation

extension Date {
    
    func year() -> Int {
        guard let year = Calendar.current.dateComponents([.year], from: self).year else { return 2022 }
        return year
    }
    
    func month() -> Int {
        guard let month = Calendar.current.dateComponents([.month], from: self).month else { return 12 }
        return month
    }
    
    func yearDifference(byAdding value: Int) -> Int {
        guard let date = Calendar.current.date(byAdding: .year, value: value, to: self) else { return 0 }
        return date.year()
    }
}
