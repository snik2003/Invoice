//
//  ItemModel+CoreDataProperties.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//
//

import Foundation
import CoreData

extension ItemModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemModel> {
        return NSFetchRequest<ItemModel>(entityName: "ItemModel")
    }

    @NSManaged public var itemId: String
    @NSManaged public var name: String
    @NSManaged public var amount: Double
    @NSManaged public var quantity: Int64
    @NSManaged public var discountType: Int64
    @NSManaged public var discountValue: Double
    @NSManaged public var taxable: Bool
    @NSManaged public var taxValue: Double
    @NSManaged public var taxType: Int64
    @NSManaged public var date: Date

}

extension ItemModel : Identifiable {

}
