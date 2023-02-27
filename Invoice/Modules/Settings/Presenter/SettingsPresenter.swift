//
//  SettingsPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol SettingsViewOutput: BaseViewOutput {
    func viewLoaded()
    func stringAmount(_ value: Double) -> String
    func stringPercent(_ value: Double) -> String
    func currencyDataSource() -> [String: String]
}

final class SettingsPresenter: BasePresenter {
    
    weak var view: SettingsViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
    
    private var percentFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
}

extension SettingsPresenter: SettingsViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
    
    func stringAmount(_ value: Double) -> String {
        guard let string = percentFormatter.string(from: NSNumber(value: value)) else { return "0" }
        return string
    }
    
    func stringPercent(_ value: Double) -> String {
        guard let string = percentFormatter.string(from: NSNumber(value: value)) else { return "0%" }
        return string + "%"
    }
    
    func currencyDataSource() -> [String: String] {
        let identifiers = Locale.availableIdentifiers
        var names: [String: String] = [:]
        
        for identifier in identifiers {
            let locale = Locale(identifier: identifier)
            
            let formatter = NumberFormatter()
            formatter.locale = locale
            
            guard let code = locale.currencyCode else { continue }
            guard let name = Locale.current.localizedString(forCurrencyCode: code) else { continue }
            guard let symbol = formatter.currencySymbol else { continue }
            names[name.capitalizingFirstLetter()] = " " + symbol.convertToCurrencySymbol()
        }
        
        return names
    }
    
}


