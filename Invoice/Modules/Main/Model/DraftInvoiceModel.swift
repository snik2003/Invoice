//
//  DraftInvoiceModel.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import Foundation

struct DraftInvoiceModel {
    var currentNumber = 0
    var currentNumberString = ""
    var currentIssueDate = ""
    var currentDueDate = ""
    var client: ClientModel?
    var draftItems: [DraftItemModel] = []
    var items: [ItemModel] = []
    
    var paidDate: Date?
    var paid = false
    
    var notes: String?
    
    static func initForEdit(model: InvoiceModel, delegate: MainViewController) -> DraftInvoiceModel? {
        guard let presenter = delegate.presenter else { return nil }
        
        var draft = DraftInvoiceModel()
        draft.currentNumber = Int(model.invoiceId)
        draft.currentNumberString = model.invoiceString
        draft.currentIssueDate = presenter.stringDate(model.issueDate)
        draft.currentDueDate = presenter.stringDate(model.dueDate)
        draft.client = delegate.clients.filter({ $0.clientId == model.clientId }).first
        draft.draftItems = model.convertDataToItems() ?? []
        draft.items = []
        
        draft.paidDate = model.paidDate
        draft.paid = model.paidDate != nil
        
        draft.notes = model.notes
        
        return draft
    }
    
    static func initForDublicate(model: InvoiceModel, delegate: MainViewController) -> DraftInvoiceModel? {
        guard let presenter = delegate.presenter else { return nil }
        let number = presenter.invoiceNumber()
        let dueDate = presenter.dueDate()
        
        var draft = DraftInvoiceModel()
        draft.currentNumber = number.0
        draft.currentNumberString = number.1
        draft.currentIssueDate = presenter.stringDate(Date())
        draft.currentDueDate = presenter.stringDate(dueDate)
        draft.client = delegate.clients.filter({ $0.clientId == model.clientId }).first
        draft.draftItems = model.convertDataToItems() ?? []
        draft.items = []
        
        draft.paidDate = nil
        draft.paid = false
        
        draft.notes = model.notes
        
        return draft
    }
    
    var notesPlaceholder: String {
        return "add.invoice.notes.text.view.placeholder".localized()
    }
    
    var subtotal: Double {
        var subtotal = 0.0
        
        for item in draftItems {
            subtotal += item.amount * Double(item.quantity)
        }
        
        for item in items {
            subtotal += item.amount * Double(item.quantity)
        }
        
        return subtotal
    }
    
    var discount: Double {
        var discount = 0.0
        
        for item in draftItems {
            if item.discountType == DiscountModel.percentage.rawValue {
                let value = item.discountValue * item.amount / 100
                discount += value * Double(item.quantity)
            } else if item.discountType == DiscountModel.fixed.rawValue {
                discount += item.discountValue * Double(item.quantity)
            }
        }
        
        for item in items {
            if item.discountType == DiscountModel.percentage.rawValue {
                let value = item.discountValue * item.amount / 100
                discount += value * Double(item.quantity)
            } else if item.discountType == DiscountModel.fixed.rawValue {
                discount += item.discountValue * Double(item.quantity)
            }
        }
        
        return discount > 0 ? -1 * discount : 0
    }
    
    var tax: Double {
        var tax = 0.0
        
        for item in draftItems {
            guard item.taxable else { continue }
            
            var amount = item.amount - item.discountValue
            if item.discountType == DiscountModel.percentage.rawValue {
                amount = item.amount - item.discountValue * item.amount / 100
            }
            
            if item.taxType == TaxModel.onTotal.rawValue {
                tax += item.taxValue * amount * Double(item.quantity) / 100
            } else if item.taxType == TaxModel.deducted.rawValue {
                tax -= item.taxValue * amount * Double(item.quantity) / 100
            }
        }
        
        for item in items {
            guard item.taxable else { continue }
            
            var amount = item.amount - item.discountValue
            if item.discountType == DiscountModel.percentage.rawValue {
                amount = item.amount - item.discountValue * item.amount / 100
            }
            
            if item.taxType == TaxModel.onTotal.rawValue {
                tax += item.taxValue * amount * Double(item.quantity) / 100
            } else if item.taxType == TaxModel.deducted.rawValue {
                tax -= item.taxValue * amount * Double(item.quantity) / 100
            }
        }
        
        return tax
    }
    
    var total: Double {
        return subtotal + discount + tax
    }
    
    var balance: Double {
        guard paid else { return total }
        return 0
    }
    
    func convertItemsToData() -> Data? {
        var draftItems = self.draftItems
        
        for item in self.items {
            draftItems.append(DraftItemModel(model: item))
        }
        
        guard let data = try? JSONEncoder().encode(draftItems) else { return nil }
        return data
    }
}
