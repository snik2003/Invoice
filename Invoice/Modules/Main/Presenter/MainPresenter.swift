//
//  MainPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol MainViewOutput: BaseViewOutput {
    func viewLoaded()
    func stringDate(_ date: Date) -> String
    func stringAmount(_ value: Double) -> String
    func dueDate() -> Date
    func invoiceHeaderForMenu(_ model: InvoiceModel, clients: [ClientModel]) -> String
}

final class MainPresenter: BasePresenter {
    
    weak var view: MainViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter
    }
    
    private var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
    
    private var zeroValue: String {
        guard let separator = Locale.current.decimalSeparator else { return "0.00" + currencySymbol() }
        return "0" + separator + "00" + currencySymbol()
    }
}

extension MainPresenter: MainViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
    
    func stringDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func stringAmount(_ value: Double) -> String {
        guard let string = numberFormatter.string(from: NSNumber(value: value)) else { return zeroValue }
        return string + currencySymbol()
    }
    
    func dueDate() -> Date {
        let calendar = Calendar.current
        guard let dueDate = calendar.date(byAdding: .day, value: Constants.shared.dueDateIncrementFromIssueDate, to: Date()) else {
            return Date()
        }
        
        return dueDate
    }
    
    func invoiceHeaderForMenu(_ model: InvoiceModel, clients: [ClientModel]) -> String {
        guard let items = model.convertDataToItems(), let item = items.first else {
            return "Invoice " + model.invoiceString + "\n" + stringAmount(model.total)
        }
        
        guard let client = clients.filter({ $0.clientId == model.clientId }).first else {
            return "Invoice " + model.invoiceString + "\n" + item.name + (items.count == 1 ? "" : " ...")
        }
        
        return "Invoice " + model.invoiceString + "\n" + client.name
        //return "Invoice " + model.invoiceString + "\n" + item.name + (items.count == 1 ? "\n" : " ...\n") + client.name
    }
}

