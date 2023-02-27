//
//  DraftItemModel.swift
//  Invoice
//
//  Created by Сергей Никитин on 01.12.2022.
//

import Foundation

struct DraftItemModel: Encodable, Decodable {
    var itemId: String
    var name: String
    var amount: Double
    var quantity: Int64
    var discountType: Int64
    var discountValue: Double
    var taxable: Bool
    var taxValue: Double
    var taxType: Int64
    var date: Date
    
    init(model: ItemModel) {
        self.itemId = model.itemId + "_draft"
        self.name = model.name
        self.amount = model.amount
        self.quantity = model.quantity
        self.discountType = model.discountType
        self.discountValue = model.discountValue
        self.taxable = model.taxable
        self.taxValue = model.taxValue
        self.taxType = model.taxType
        self.date = model.date
    }
    
    var discount: Double {
        var discount = discountValue * Double(quantity)
        
        if discountType == DiscountModel.percentage.rawValue {
            discount = discountValue * amount / 100 * Double(quantity)
        }
    
        return discount > 0 ? -1 * discount : 0
    }
    
    var tax: Double {
        var tax = 0.0
        guard taxable else { return tax }
        
        var amount = self.amount - discountValue
        if discountType == DiscountModel.percentage.rawValue {
            amount = self.amount - discountValue * self.amount / 100
        }
        
        if taxType == TaxModel.onTotal.rawValue {
            tax = taxValue * amount * Double(quantity) / 100
        } else if taxType == TaxModel.deducted.rawValue {
            tax = -1 * taxValue * amount * Double(quantity) / 100
        }
        
        return tax
    }
    
    var total: Double {
        return amount * Double(quantity) + discount + tax
    }
}
