//
//  Constants.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit
import StoreKit
import ApphudSDK

let emptyClosure: () -> Void = {  }

typealias EmptyBlock = () -> Void
typealias SearchValueBlock = (String) -> Void
typealias SuccessfulCompletion = (_ success: Bool) -> ()
typealias ErrorCompletion = (_ error: String?) -> Void

final class Constants {
    static let shared = Constants()
    
    let testBundleID = "com.reapps.invoice"
    
    // устанавливать true только для тестирования приложения
    let isTestMode = true
    
    // количество пульсирующих анимаций на главном экране
    let maxPulseAnimationCount = 6
    
    // Api_key для интеграции AppHud
    let appHudApiKey = ""
    
    // Api_key для интеграции Yandex AppMetrics
    let appMetrikaApiKey = ""
    
    // Api_key для интеграции Google Firebase Analitycs
    let firebaseBundle = ""
    
    // Api_key для интеграции OneSignal PushNotifications
    let oneSignalAppID = ""
    
    // URL раздела "Contact Developer"
    let contactDeveloperURL = "https://www.apple.com/ru/contact/"
    
    // URL раздела "Terms of Use"
    let termsOfUseURL = "https://www.apple.com/ru/legal/warranty/"
    
    // URL раздела "Privacy Policy"
    let privacyPolicyURL = "https://www.apple.com/ru/privacy/"
    
    // AppHud integration
    let paywallIdentifier = "Premium"
    
    // Products for Paywall
    var storeProducts: [SKProduct] = []
    var apphudProducts: [ApphudProduct] = []
    
    let dueDateIncrementFromIssueDate = 14
    
    var invoiceSearchText = ""
    var clientSearchText = ""
    var itemSearchText = ""
    
    var freeModeMaxClients = 5
    var freeModeMaxitems = 10
}

extension Constants {
    
    func getStoreProducts() {
        storeProducts = []
        
        for index in 0 ..< apphudProducts.count {
            guard let product = apphudProducts[index].skProduct else { continue }
            storeProducts.append(product)
        }
        
        guard isTestMode else { return }
        guard storeProducts.isEmpty else { return }
        storeProducts = PSKProduct.getDemoProducts()
    }
}
