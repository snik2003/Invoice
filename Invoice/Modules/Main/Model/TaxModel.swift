//
//  TaxModel.swift
//  Invoice
//
//  Created by Сергей Никитин on 01.12.2022.
//

import Foundation

enum TaxModel: Int, CaseIterable {
    case onTotal = 1
    case deducted = 2
    
    var title: String {
        switch self {
        case .onTotal:
            return "On the total"
        case .deducted:
            return "Deducted"
        }
    }
    
    static func getTaxModel(from value: Int) -> TaxModel? {
        return TaxModel.allCases.filter({ $0.rawValue == value }).first
    }
}
