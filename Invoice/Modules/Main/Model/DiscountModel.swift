//
//  DiscountModel.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//

import Foundation

enum DiscountModel: Int, CaseIterable {
    case percentage = 1
    case fixed = 2
    
    var title: String {
        switch self {
        case .percentage:
            return "Percentage"
        case .fixed:
            return "Fixed Amount"
        }
    }
    
    static func getDiscountModel(from value: Int) -> DiscountModel? {
        return DiscountModel.allCases.filter({ $0.rawValue == value }).first
    }
}
