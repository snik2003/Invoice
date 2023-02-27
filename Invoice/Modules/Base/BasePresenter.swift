//
//  BasePresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation
import CoreData

protocol BaseViewOutput {
    func isPremium() -> Bool
    func setPremiumMode(_ status: Bool)
    func isFirstInvoice(_ template: Int) -> Bool
    func setupFirstInvoice(_ template: Int)
    func canShare(_ template: Int) -> Bool

    func bussinessName() -> String?
    func setBussinessName(_ name: String)
    func bussinessNumber() -> String?
    func setBussinessNumber(_ number: String?)
    func bussinessEmail() -> String?
    func setBussinessEmail(_ email: String?)
    func bussinessPhone() -> String?
    func setBussinessPhone(_ phone: String?)
    func bussinessWebsite() -> String?
    func setBussinessWebsite(_ site: String?)
    func bussinessAddress() -> String?
    func setBussinessAddress(_ address: String?)
    
    func currencySymbol() -> String
    func setCurrencySymbol(_ value: String)
    func currencyName() -> String
    func setCurrencyName(_ value: String)
    
    func invoiceNumber() -> (Int,String)
    func incInvoiceNumber(_ currentNumber: Int)
    
    func taxable() -> Bool
    func setTaxable(_ value: Bool)
    func taxType() -> TaxModel
    func setTaxType(_ type: TaxModel)
    func taxValue() -> Double
    func setTaxValue(_ value: Double)
    
    func clientsCount() -> Int
    func loadClients(completion: @escaping ([ClientModel]) -> Void)
    func deleteClients(completion: @escaping EmptyBlock)
    
    func itemsCount() -> Int
    func loadItems(completion: @escaping ([ItemModel]) -> Void)
    func deleteItems(completion: @escaping EmptyBlock)
    
    func loadInvoices(completion: @escaping ([InvoiceModel]) -> Void)
}

class BasePresenter: BaseViewOutput {
    
    func isPremium() -> Bool {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.isPremiumMode
    }
    
    func setPremiumMode(_ status: Bool) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.isPremiumMode = status
    }
    
    func isFirstInvoice(_ template: Int) -> Bool {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        if template == 1 { return appDataService.firstInvoice1 }
        if template == 2 { return appDataService.firstInvoice2 }
        if template == 3 { return appDataService.firstInvoice3 }
        return false
    }
    
    func setupFirstInvoice(_ template: Int) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        
        appDataService.firstInvoice1 = false
        appDataService.firstInvoice2 = false
        appDataService.firstInvoice3 = false
        
        /*
        if template == 1 {
            guard appDataService.firstInvoice1 else { return }
            appDataService.firstInvoice1 = false
        } else if template == 2 {
            guard appDataService.firstInvoice2 else { return }
            appDataService.firstInvoice2 = false
        } else if template == 3 {
            guard appDataService.firstInvoice3 else { return }
            appDataService.firstInvoice3 = false
        }*/
    }
    
    func canShare(_ template: Int) -> Bool {
        guard isPremium() || isFirstInvoice(template) else { return false }
        return true
    }
    
    func bussinessName() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.bussinessName
    }
    
    func setBussinessName(_ name: String) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.bussinessName = name
    }
    
    func bussinessNumber() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.bussinessNumber
    }
    
    func setBussinessNumber(_ number: String?) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.bussinessNumber = number
    }
    
    func bussinessEmail() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.bussinessEmail
    }
    
    func setBussinessEmail(_ email: String?) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.bussinessEmail = email
    }
    
    func bussinessPhone() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.bussinessPhone
    }
    
    func setBussinessPhone(_ phone: String?) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.bussinessPhone = phone
    }
    
    func bussinessWebsite() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.bussinessWebsite
    }
    
    func setBussinessWebsite(_ site: String?) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.bussinessWebsite = site
    }
    
    func bussinessAddress() -> String? {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.bussinessAddress
    }
    
    func setBussinessAddress(_ address: String?) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.bussinessAddress = address
    }
    
    func currencySymbol() -> String {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.currencySymbol
    }
    
    func setCurrencySymbol(_ value: String) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.currencySymbol = value
    }
    
    func currencyName() -> String {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.currencyName
    }
    
    func setCurrencyName(_ value: String) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.currencyName = value
    }
    
    func invoiceNumber() -> (Int,String) {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return (appDataService.invoiceNumber, String(format: "%04d", appDataService.invoiceNumber))
    }
    
    func incInvoiceNumber(_ currentNumber: Int) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        guard appDataService.invoiceNumber == currentNumber else { return }
        appDataService.invoiceNumber = appDataService.invoiceNumber + 1
    }
    
    func taxable() -> Bool {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.taxable
    }
    
    func setTaxable(_ value: Bool) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.taxable = value
    }
    
    func taxType() -> TaxModel {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return TaxModel.getTaxModel(from: appDataService.taxType) ?? TaxModel.onTotal
    }
    
    func setTaxType(_ type: TaxModel) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.taxType = type.rawValue
    }
    
    func taxValue() -> Double {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.taxValue
    }
    
    func setTaxValue(_ value: Double) {
        var appDataService: AppDataServiceProtocol = serviceLocator.getService()
        appDataService.taxValue = value
    }
    
    func clientsCount() -> Int {
        let fetch: NSFetchRequest<ClientModel> = ClientModel.fetchRequest()
        let managedContext = AppDelegate.shared.coreDataStack.managedContext
        
        do {
            let count = try managedContext.count(for: fetch)
            return count
        } catch {
            return 0
        }
    }
    
    func loadClients(completion: @escaping ([ClientModel]) -> Void) {
            
        let fetch: NSFetchRequest<ClientModel> = ClientModel.fetchRequest()
        
        do {
            let managedContext = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { results in
                if let clients = results.finalResult  {
                    completion(clients)
                }
            }
            
            try managedContext.execute(asynchronousFetchRequest)
        } catch {
            completion([])
        }
    }
    
    func deleteClients(completion: @escaping EmptyBlock) {
            
        let fetch: NSFetchRequest<ClientModel> = ClientModel.fetchRequest()
    
        do {
            let managedContext = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                DispatchQueue.main.async {
                    if let clients = results.finalResult {
                        for client in clients {
                            AppDelegate.shared.coreDataStack.managedContext.delete(client)
                            AppDelegate.shared.coreDataStack.saveContext()
                        }
                        
                        completion()
                    }
                }
            }
                
            try managedContext.execute(asynchronousFetchRequest)
        } catch {
            completion()
        }
    }
    
    func itemsCount() -> Int {
        let fetch: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
        let managedContext = AppDelegate.shared.coreDataStack.managedContext
        
        do {
            let count = try managedContext.count(for: fetch)
            return count
        } catch {
            return 0
        }
    }
    
    func loadItems(completion: @escaping ([ItemModel]) -> Void) {
            
        let fetch: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
        
        do {
            let managedContext = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { results in
                if let items = results.finalResult  {
                    completion(items)
                }
            }
            
            try managedContext.execute(asynchronousFetchRequest)
        } catch {
            completion([])
        }
    }
    
    func deleteItems(completion: @escaping EmptyBlock) {
            
        let fetch: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
    
        do {
            let managedContext = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) -> Void in
                DispatchQueue.main.async {
                    if let items = results.finalResult {
                        for item in items {
                            AppDelegate.shared.coreDataStack.managedContext.delete(item)
                            AppDelegate.shared.coreDataStack.saveContext()
                        }
                        
                        completion()
                    }
                }
            }
                
            try managedContext.execute(asynchronousFetchRequest)
        } catch {
            completion()
        }
    }
    
    func loadInvoices(completion: @escaping ([InvoiceModel]) -> Void) {
            
        let fetch: NSFetchRequest<InvoiceModel> = InvoiceModel.fetchRequest()
        
        do {
            let managedContext = AppDelegate.shared.coreDataStack.managedContext
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetch) { results in
                if let invoices = results.finalResult  {
                    completion(invoices)
                }
            }
            
            try managedContext.execute(asynchronousFetchRequest)
        } catch {
            completion([])
        }
    }
}

