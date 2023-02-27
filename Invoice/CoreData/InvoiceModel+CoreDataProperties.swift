//
//  InvoiceModel+CoreDataProperties.swift
//  Invoice
//
//  Created by Сергей Никитин on 01.12.2022.
//
//

import Foundation
import CoreData


extension InvoiceModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InvoiceModel> {
        return NSFetchRequest<InvoiceModel>(entityName: "InvoiceModel")
    }

    @NSManaged public var invoiceId: Int64
    @NSManaged public var invoiceString: String
    @NSManaged public var clientId: String
    @NSManaged public var items: Data
    @NSManaged public var issueDate: Date
    @NSManaged public var dueDate: Date
    @NSManaged public var paidDate: Date?
    @NSManaged public var notes: String?
    
}

extension InvoiceModel : Identifiable {

}
