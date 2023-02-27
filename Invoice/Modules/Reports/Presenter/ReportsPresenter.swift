//
//  ReportsPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol ReportsViewOutput: BaseViewOutput {
    func viewLoaded()
    func month(from date: Date) -> String
    func stringAmount(_ value: Double) -> String
    func totalAmount(for invoices: [InvoiceModel], inYear year: Int) -> Double
    func yearStat(for year: Int, invoices: [InvoiceModel]) -> (Int, Int, String)
    func monthStat(for year: Int, invoices: [InvoiceModel]) -> [(String, Int, Int, String)]
}

final class ReportsPresenter: BasePresenter {
    
    weak var view: ReportsViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
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

extension ReportsPresenter: ReportsViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
    
    func month(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func stringAmount(_ value: Double) -> String {
        guard let string = numberFormatter.string(from: NSNumber(value: value)) else { return zeroValue }
        return string + currencySymbol()
    }
    
    func totalAmount(for invoices: [InvoiceModel], inYear year: Int) -> Double {
        var total = 0.0
        for invoice in invoices {
            guard year == invoice.issueDate.year() else { continue }
            total += invoice.total
        }
        return total
    }
    
    func yearStat(for year: Int, invoices: [InvoiceModel]) -> (Int, Int, String) {
        var clients: [String] = []
        var invoicesCount = 0
        var paidAmount = 0.0
        
        for invoice in invoices {
            guard year == invoice.issueDate.year() else { continue }
            
            if !clients.contains(invoice.clientId) { clients.append(invoice.clientId) }
            invoicesCount += 1
            
            guard invoice.paidDate != nil else { continue }
            paidAmount += invoice.total
        }
        
        return (clients.count, invoicesCount, stringAmount(paidAmount))
    }
    
    func monthStat(for year: Int, invoices: [InvoiceModel]) -> [(String, Int, Int, String)] {
        
        var result: [(String, Int, Int, String)] = []
        
        for month in 1 ... 12 {
            if year == Date().year() && month > Date().month() { continue }
            
            var dates: [Date] = []
            var clients: [String] = []
            var invoicesCount = 0
            var paidAmount = 0.0
            
            for invoice in invoices {
                guard year == invoice.issueDate.year() else { continue }
                guard month == invoice.issueDate.month() else { continue }
                
                if !clients.contains(invoice.clientId) { clients.append(invoice.clientId) }
                dates.append(invoice.issueDate)
                invoicesCount += 1
                
                guard invoice.paidDate != nil else { continue }
                paidAmount += invoice.total
            }
            
            let monthName = dateFormatter.monthSymbols[month - 1]
            result.append((monthName, clients.count, invoicesCount, stringAmount(paidAmount)))
            
            /*if let date = dates.first {
                let monthName = self.month(from: date)
                result.append((monthName, clients.count, invoicesCount, stringAmount(paidAmount)))
            } else {
                let monthName = String(format: "%4d", month)
                result.append((monthName, clients.count, invoicesCount, stringAmount(paidAmount)))
            }*/
        }
        
        return result.reversed()
    }
}


