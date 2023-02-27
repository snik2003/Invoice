//
//  AppDataService.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation
import KeychainSwift

fileprivate enum AppDataKey: String {
    case firstLaunchKey
    case firstInvoice1Key
    case firstInvoice2Key
    case firstInvoice3Key
    case isPremiumModeKey
    case bussinessNameKey
    case bussinessNumberKey
    case bussinessEmailKey
    case bussinessPhoneKey
    case bussinessWebsiteKey
    case bussinessAddressKey
    case invoiceNumberKey
    case taxableKey
    case taxTypeKey
    case taxValueKey
    case currencySymbolKey
    case currencyNameKey
}

protocol AppDataServiceProtocol {
    var firstLaunch: Bool { get set }
    var firstInvoice1: Bool { get set }
    var firstInvoice2: Bool { get set }
    var firstInvoice3: Bool { get set }
    var isPremiumMode: Bool { get set }
    var bussinessName: String? { get set }
    var bussinessNumber: String? { get set }
    var bussinessEmail: String? { get set }
    var bussinessPhone: String? { get set }
    var bussinessWebsite: String? { get set }
    var bussinessAddress: String? { get set }
    var invoiceNumber: Int { get set }
    var taxable: Bool { get set }
    var taxType: Int { get set }
    var taxValue: Double { get set }
    var currencySymbol: String { get set }
    var currencyName: String { get set }
}

final class AppDataService {
    
    private let userDefaults: UserDefaults
    private let keychain: KeychainSwift
    
    init() {
        userDefaults = UserDefaults()
        keychain = KeychainSwift()
    }
    
    private var currencySymbolDefault: String {
        let identifier = Locale.current.identifier
        let locale = Locale(identifier: identifier)
        
        let formatter = NumberFormatter()
        formatter.locale = locale
        
        guard let currencySymbol = formatter.currencySymbol else { return " $" }
        return " " + currencySymbol.convertToCurrencySymbol()
    }
    
    private var currencyNameDefault: String {
        let identifier = Locale.current.identifier
        let locale = Locale(identifier: identifier)
        
        guard let currencyCode = locale.currencyCode else { return "US Dollar" }
        guard let currencyName = Locale.current.localizedString(forCurrencyCode: currencyCode) else { return "US Dollar" }
        
        return currencyName.capitalizingFirstLetter()
    }
}

//MARK:- UserDataServiceProtocol
extension AppDataService: AppDataServiceProtocol {
    
    var firstLaunch: Bool {
        get { return boolValue(for: .firstLaunchKey) ?? true }
        set { setValue(newValue, for: .firstLaunchKey) }
    }
    
    var firstInvoice1: Bool {
        get { return boolValue(for: .firstInvoice1Key) ?? true }
        set { setValue(newValue, for: .firstInvoice1Key) }
    }
    
    var firstInvoice2: Bool {
        get { return boolValue(for: .firstInvoice2Key) ?? true }
        set { setValue(newValue, for: .firstInvoice2Key) }
    }
    
    var firstInvoice3: Bool {
        get { return boolValue(for: .firstInvoice3Key) ?? true }
        set { setValue(newValue, for: .firstInvoice3Key) }
    }
    
    var isPremiumMode: Bool {
        get { return boolValue(for: .isPremiumModeKey) ?? false }
        set { setValue(newValue, for: .isPremiumModeKey) }
    }
    
    var bussinessName: String? {
        get { return value(for: .bussinessNameKey) }
        set { setValue(newValue, for: .bussinessNameKey) }
    }
    
    var bussinessNumber: String? {
        get { return value(for: .bussinessNumberKey) }
        set { setValue(newValue, for: .bussinessNumberKey) }
    }
    
    var bussinessEmail: String? {
        get { return value(for: .bussinessEmailKey) }
        set { setValue(newValue, for: .bussinessEmailKey) }
    }
    
    var bussinessPhone: String? {
        get { return value(for: .bussinessPhoneKey) }
        set { setValue(newValue, for: .bussinessPhoneKey) }
    }
    
    var bussinessWebsite: String? {
        get { return value(for: .bussinessWebsiteKey) }
        set { setValue(newValue, for: .bussinessWebsiteKey) }
    }
    
    var bussinessAddress: String? {
        get { return value(for: .bussinessAddressKey) }
        set { setValue(newValue, for: .bussinessAddressKey) }
    }
    
    var invoiceNumber: Int {
        get { return intValue(for: .invoiceNumberKey) ?? 1 }
        set { setValue(newValue, for: .invoiceNumberKey) }
    }
    
    var taxable: Bool {
        get { return boolValue(for: .taxableKey) ?? false }
        set { setValue(newValue, for: .taxableKey) }
    }
    
    var taxType: Int {
        get { return intValue(for: .taxTypeKey) ?? TaxModel.onTotal.rawValue }
        set { setValue(newValue, for: .taxTypeKey) }
    }
    
    var taxValue: Double {
        get { return anyValue(for: .taxValueKey) as? Double ?? 18.0 }
        set { setValue(newValue, for: .taxValueKey) }
    }
    
    var currencySymbol: String {
        get { return value(for: .currencySymbolKey) ?? currencySymbolDefault }
        set { setValue(newValue, for: .currencySymbolKey) }
    }
    
    var currencyName: String {
        get { return value(for: .currencyNameKey) ?? currencyNameDefault }
        set { setValue(newValue, for: .currencyNameKey) }
    }
}

//MARK:- Setup values
extension AppDataService {
    
    fileprivate func value(for key: AppDataKey) -> String? {
        return userDefaults.object(forKey: key.rawValue) as? String
    }
    
    fileprivate func masStringValue(for key: AppDataKey) -> [String]? {
        return userDefaults.object(forKey: key.rawValue) as? [String]
    }
    
    fileprivate func boolValue(for key: AppDataKey) -> Bool? {
        return userDefaults.object(forKey: key.rawValue) as? Bool
    }
    
    fileprivate func intValue(for key: AppDataKey) -> Int? {
        return userDefaults.object(forKey: key.rawValue) as? Int
    }
    
    fileprivate func anyValue(for key: AppDataKey) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }
    
    fileprivate func setValue(_ value: Any?, for key: AppDataKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    fileprivate func setSecureValue(_ value: String?, for key: AppDataKey) {
        guard let value = value else { self.keychain.delete(key.rawValue); return }
        keychain.set(value, forKey: key.rawValue)
    }
    
    fileprivate func secureValue(for key: AppDataKey) -> String? {
        return keychain.get(key.rawValue)
    }
}

