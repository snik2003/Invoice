//
//  InvoiceModel+CoreDataClass.swift
//  Invoice
//
//  Created by Сергей Никитин on 01.12.2022.
//
//

import Foundation
import CoreData

@objc(InvoiceModel)
public class InvoiceModel: NSManagedObject {
    
    static func saveInvoice(_ draft: DraftInvoiceModel, issueDate: Date, dueDate: Date, itemsData: Data, notes: String?,
                            completion: @escaping (InvoiceModel?) -> Void) {
        
        guard let client = draft.client else {
            completion(nil)
            return
        }
        
        let fetch: NSFetchRequest<InvoiceModel> = InvoiceModel.fetchRequest()
        
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                if let savedInvoice = results.finalResult?.filter({ $0.invoiceId == draft.currentNumber }).first {
                    savedInvoice.setValue(client.clientId, forKey: #keyPath(InvoiceModel.clientId))
                    savedInvoice.setValue(itemsData, forKey: #keyPath(InvoiceModel.items))
                    savedInvoice.setValue(issueDate, forKey: #keyPath(InvoiceModel.issueDate))
                    savedInvoice.setValue(dueDate, forKey: #keyPath(InvoiceModel.dueDate))
                    savedInvoice.setValue(notes, forKey: #keyPath(InvoiceModel.notes))
                    
                    AppDelegate.shared.coreDataStack.saveContext()
                    completion(savedInvoice)
                    return
                }
                
                let invoice = InvoiceModel(context: context)
                invoice.setValue(draft.currentNumber, forKey: #keyPath(InvoiceModel.invoiceId))
                invoice.setValue("INV" + draft.currentNumberString, forKey: #keyPath(InvoiceModel.invoiceString))
                invoice.setValue(client.clientId, forKey: #keyPath(InvoiceModel.clientId))
                invoice.setValue(itemsData, forKey: #keyPath(InvoiceModel.items))
                invoice.setValue(issueDate, forKey: #keyPath(InvoiceModel.issueDate))
                invoice.setValue(dueDate, forKey: #keyPath(InvoiceModel.dueDate))
                invoice.setValue(nil, forKey: #keyPath(InvoiceModel.paidDate))
                invoice.setValue(notes, forKey: #keyPath(InvoiceModel.notes))
                
                AppDelegate.shared.coreDataStack.saveContext()
                completion(invoice)
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion(nil)
        }
    }
    
    static func paidInvoice(_ invoice: InvoiceModel, completion: @escaping EmptyBlock) {
        
        let fetch: NSFetchRequest<InvoiceModel> = InvoiceModel.fetchRequest()
                
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                if let paidedInvoice = results.finalResult?.filter({ $0.invoiceId == invoice.invoiceId }).first {
                    paidedInvoice.setValue(Date(), forKey: #keyPath(InvoiceModel.paidDate))
                    AppDelegate.shared.coreDataStack.saveContext()
                    
                    completion()
                }
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion()
        }
    }
    
    static func unpaidInvoice(_ invoice: InvoiceModel, completion: @escaping EmptyBlock) {
        
        let fetch: NSFetchRequest<InvoiceModel> = InvoiceModel.fetchRequest()
                
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                if let paidedInvoice = results.finalResult?.filter({ $0.invoiceId == invoice.invoiceId }).first {
                    paidedInvoice.setValue(nil, forKey: #keyPath(InvoiceModel.paidDate))
                    AppDelegate.shared.coreDataStack.saveContext()
                    
                    completion()
                }
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion()
        }
    }
    
    static func deleteInvoice(_ invoice: InvoiceModel, completion: @escaping EmptyBlock) {
        
        let fetch: NSFetchRequest<InvoiceModel> = InvoiceModel.fetchRequest()
                
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                if let deletedInvoice = results.finalResult?.filter({ $0.invoiceId == invoice.invoiceId }).first {
                    AppDelegate.shared.coreDataStack.managedContext.delete(deletedInvoice)
                    AppDelegate.shared.coreDataStack.saveContext()
                    
                    completion()
                }
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion()
        }
    }
    
    static func dublicateInvoice(_ invoice: InvoiceModel, number: Int, numberString: String, dueDate: Date,
                            completion: @escaping EmptyBlock) {
        
        let fetch: NSFetchRequest<InvoiceModel> = InvoiceModel.fetchRequest()
        
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                let dubInvoice = InvoiceModel(context: context)
                dubInvoice.setValue(number, forKey: #keyPath(InvoiceModel.invoiceId))
                dubInvoice.setValue("INV" + numberString, forKey: #keyPath(InvoiceModel.invoiceString))
                dubInvoice.setValue(invoice.clientId, forKey: #keyPath(InvoiceModel.clientId))
                dubInvoice.setValue(invoice.items, forKey: #keyPath(InvoiceModel.items))
                dubInvoice.setValue(Date(), forKey: #keyPath(InvoiceModel.issueDate))
                dubInvoice.setValue(dueDate, forKey: #keyPath(InvoiceModel.dueDate))
                dubInvoice.setValue(nil, forKey: #keyPath(InvoiceModel.paidDate))
                
                AppDelegate.shared.coreDataStack.saveContext()
                completion()
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion()
        }
    }
    
    func convertDataToItems() -> [DraftItemModel]? {
        let decoder = JSONDecoder()
        guard let items = try? decoder.decode([DraftItemModel].self, from: self.items) else { return nil }
        return items
    }
    
    var subtotal: Double {
        guard let items = convertDataToItems() else { return 0 }
        
        var subtotal = 0.0
        for item in items {
            subtotal += item.amount * Double(item.quantity)
        }
        return subtotal
    }
    
    var discount: Double {
        guard let items = convertDataToItems() else { return 0 }
        
        var discount = 0.0
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
        guard let items = convertDataToItems() else { return 0 }
        
        var tax = 0.0
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
        guard paidDate == nil else { return total }
        return 0.0
    }
    
    var status: String {
        guard paidDate == nil else { return "Paid" }
        guard Date() <= dueDate else { return "Not paid until" }
        return "Unpaid"
    }
    
    func checkSearch(_ searchText: String, clients: [ClientModel]) -> Bool {
        
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if let client = clients.filter({ $0.clientId == clientId }).first {
            if client.name.lowercased().contains(searchText) { return true }
            if client.email?.lowercased().contains(searchText) == true { return true }
            if client.phone?.lowercased().contains(searchText) == true { return true }
            if client.address?.lowercased().contains(searchText) == true { return true }
        }
        
        guard let items = convertDataToItems() else { return false }
        if items.filter({ $0.name.lowercased().contains(searchText) }).count > 0 { return true }
        if let value = Double(searchText.replacingOccurrences(of: ",", with: ".")), total == value { return true }
        
        return false
    }
}
