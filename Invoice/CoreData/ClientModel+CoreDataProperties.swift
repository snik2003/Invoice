//
//  ClientModel+CoreDataProperties.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//
//

import Foundation
import CoreData


extension ClientModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClientModel> {
        return NSFetchRequest<ClientModel>(entityName: "ClientModel")
    }

    @NSManaged public var address: String?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?
    @NSManaged public var name: String
    @NSManaged public var clientId: String

}

extension ClientModel : Identifiable {

}
