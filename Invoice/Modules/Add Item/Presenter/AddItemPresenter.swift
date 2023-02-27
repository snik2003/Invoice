//
//  AddItemPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//

import UIKit

protocol AddItemViewOutput: BaseViewOutput {
    func viewLoaded()
    func stringAmount(_ value: Double) -> String
    func stringDouble(_ value: Double) -> String
    func stringPercent(_ value: Double) -> String
    
}

final class AddItemPresenter: BasePresenter {
    
    weak var view: AddItemViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
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

extension AddItemPresenter: AddItemViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
    
    func stringAmount(_ value: Double) -> String {
        guard let string = numberFormatter.string(from: NSNumber(value: value)) else { return zeroValue }
        return string + currencySymbol()
    }
    
    func stringPercent(_ value: Double) -> String {
        guard let string = percentFormatter.string(from: NSNumber(value: value)) else { return "0%" }
        return string + "%"
    }
    
    func stringDouble(_ value: Double) -> String {
        guard let string = percentFormatter.string(from: NSNumber(value: value)) else { return "0" }
        return string
    }
}
