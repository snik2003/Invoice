//
//  ClientModel+CoreDataClass.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//
//

import Foundation
import CoreData

@objc(ClientModel)
public class ClientModel: NSManagedObject {

    static func addClient(_ name: String, email: String?, phone: String?, address: String?,
                          completion: @escaping (ClientModel?) -> Void) {
                    
        let fetch: NSFetchRequest<ClientModel> = ClientModel.fetchRequest()
        
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                let client = ClientModel(context: context)
                client.setValue(UUID().uuidString, forKey: #keyPath(ClientModel.clientId))
                client.setValue(name, forKey: #keyPath(ClientModel.name))
                client.setValue(email, forKey: #keyPath(ClientModel.email))
                client.setValue(phone, forKey: #keyPath(ClientModel.phone))
                client.setValue(address, forKey: #keyPath(ClientModel.address))
                
                AppDelegate.shared.coreDataStack.saveContext()
                completion(client)
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion(nil)
        }
    }
    
    static func updateClient(_ client: ClientModel, name: String, email: String?, phone: String?, address: String?,
                             completion: @escaping (ClientModel) -> Void) {
        
        let fetch: NSFetchRequest<ClientModel> = ClientModel.fetchRequest()
                
        do {
            let context = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                
                if let updatedClient = results.finalResult?.filter({ $0.clientId == client.clientId }).first {
                    updatedClient.setValue(name, forKey: #keyPath(ClientModel.name))
                    updatedClient.setValue(email, forKey: #keyPath(ClientModel.email))
                    updatedClient.setValue(phone, forKey: #keyPath(ClientModel.phone))
                    updatedClient.setValue(address, forKey: #keyPath(ClientModel.address))
                    AppDelegate.shared.coreDataStack.saveContext()
                    
                    completion(updatedClient)
                }
            }
                            
            try context.execute(asynchronousFetchRequest)
        } catch {
            completion(client)
        }
    }
    
    func checkSearch(_ searchText: String) -> Bool {
        
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if self.name.lowercased().contains(searchText) { return true }
        if let email = self.email, email.lowercased().contains(searchText) { return true }
        if let phone = phone, phone.lowercased().contains(searchText) == true { return true }
        if let address = self.address, address.lowercased().contains(searchText) == true { return true }
        
        return false
    }
}
