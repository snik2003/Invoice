//
//  ItemModel+CoreDataClass.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//
//

import Foundation
import CoreData

@objc(ItemModel)
public class ItemModel: NSManagedObject {
    
    static func addItem(_ name: String, amount: Double, quantity: Int, discountType: DiscountModel, discount: Double,
                        taxable: Bool, tax: Double, taxType: TaxModel, completion: @escaping (ItemModel?) -> Void) {
                    
        let fetch: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
        
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                let item = ItemModel(context: context)
                item.setValue(UUID().uuidString, forKey: #keyPath(ItemModel.itemId))
                item.setValue(name, forKey: #keyPath(ItemModel.name))
                item.setValue(amount, forKey: #keyPath(ItemModel.amount))
                item.setValue(quantity, forKey: #keyPath(ItemModel.quantity))
                item.setValue(discountType.rawValue, forKey: #keyPath(ItemModel.discountType))
                item.setValue(discount, forKey: #keyPath(ItemModel.discountValue))
                item.setValue(taxable, forKey: #keyPath(ItemModel.taxable))
                item.setValue(tax, forKey: #keyPath(ItemModel.taxValue))
                item.setValue(taxType.rawValue, forKey: #keyPath(ItemModel.taxType))
                item.setValue(Date(), forKey: #keyPath(ItemModel.date))
                
                AppDelegate.shared.coreDataStack.saveContext()
                completion(item)
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion(nil)
        }
    }
    
    static func updateItem(_ item: ItemModel, name: String, amount: Double, quantity: Int, discountType: DiscountModel, discount: Double,
                           taxable: Bool, tax: Double, taxType: TaxModel, completion: @escaping (ItemModel) -> Void) {
        
        let fetch: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                if let updatedItem = results.finalResult?.filter({ $0.itemId == item.itemId }).first {
                    updatedItem.setValue(name, forKey: #keyPath(ItemModel.name))
                    updatedItem.setValue(amount, forKey: #keyPath(ItemModel.amount))
                    updatedItem.setValue(quantity, forKey: #keyPath(ItemModel.quantity))
                    updatedItem.setValue(discountType.rawValue, forKey: #keyPath(ItemModel.discountType))
                    updatedItem.setValue(discount, forKey: #keyPath(ItemModel.discountValue))
                    updatedItem.setValue(taxable, forKey: #keyPath(ItemModel.taxable))
                    updatedItem.setValue(tax, forKey: #keyPath(ItemModel.taxValue))
                    updatedItem.setValue(taxType.rawValue, forKey: #keyPath(ItemModel.taxType))
                    updatedItem.setValue(Date(), forKey: #keyPath(ItemModel.date))
                    AppDelegate.shared.coreDataStack.saveContext()
                    
                    completion(updatedItem)
                }
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion(item)
        }
    }
    
    var discount: Double {
        let discount = discountType == DiscountModel.fixed.rawValue ? discountValue : discountValue * amount / 100
        return discount > 0 ? -1 * discount : 0
    }
    
    var tax: Double {
        guard taxable else { return 0 }
        return (taxType == TaxModel.onTotal.rawValue ? 1 : -1) * taxValue * (amount + discount) / 100
    }
    
    var total: Double {
        return (amount + discount + tax) * Double(quantity)
    }
    
    func checkSearch(_ searchText: String) -> Bool {
        
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if name.lowercased().contains(searchText) { return true }
        if amount * Double(quantity) == Double(searchText.replacingOccurrences(of: ",", with: ".")) { return true }
        return false
    }
}
