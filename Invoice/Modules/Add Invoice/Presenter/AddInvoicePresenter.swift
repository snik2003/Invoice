//
//  AddInvoicePresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit

protocol AddInvoiceViewOutput: BaseViewOutput {
    func viewLoaded()
    func stringDate(_ date: Date) -> String
    func dateString(_ string: String) -> Date?
    func stringAmount(_ value: Double) -> String
    func stringPercent(_ value: Double) -> String
    func dueDate(fromIssueDate date: Date) -> Date
    func saveInvoice(_ draft: DraftInvoiceModel, completion: @escaping (InvoiceModel?) -> Void)
}

final class AddInvoicePresenter: BasePresenter {
    
    weak var view: AddInvoiceViewInput?
    private var appDataService: AppDataServiceProtocol
    private var clients: [ClientModel]
    private var items: [ItemModel]
    
    init(clients: [ClientModel], items: [ItemModel], appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
        self.clients = clients
        self.items = items
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
    
    private var percentFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
    
    private var zeroValue: String {
        guard let separator = Locale.current.decimalSeparator else { return "0.00" + currencySymbol() }
        return "0" + separator + "00" + currencySymbol()
    }
}

extension AddInvoicePresenter: AddInvoiceViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState(clients: clients, items: items)
    }
    
    func stringDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func dateString(_ string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
    
    func stringAmount(_ value: Double) -> String {
        guard let string = numberFormatter.string(from: NSNumber(value: value)) else { return zeroValue }
        return string + currencySymbol()
    }
    
    func stringPercent(_ value: Double) -> String {
        guard let string = percentFormatter.string(from: NSNumber(value: value)) else { return "0%" }
        return string + "%"
    }
    
    func dueDate(fromIssueDate date: Date) -> Date {
        guard let dueDate = Calendar.current.date(byAdding: .day, value: Constants.shared.dueDateIncrementFromIssueDate, to: date) else {
            return date
        }
        
        return dueDate
    }
    
    func saveInvoice(_ draft: DraftInvoiceModel, completion: @escaping (InvoiceModel?) -> Void) {
        
        guard let issueDate = dateString(draft.currentIssueDate) else { completion(nil); return }
        guard let dueDate = dateString(draft.currentDueDate) else { completion(nil); return }
        guard let itemsData = draft.convertItemsToData() else { completion(nil); return }
        
        view?.showLoading()
        InvoiceModel.saveInvoice(draft, issueDate: issueDate, dueDate: dueDate, itemsData: itemsData, notes: draft.notes) { invoice in 
            self.incInvoiceNumber(draft.currentNumber)
            self.view?.hideLoading()
            completion(invoice)
        }
    }
}

