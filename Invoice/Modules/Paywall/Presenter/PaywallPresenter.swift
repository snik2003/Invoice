//
//  PaywallPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol PaywallViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class PaywallPresenter: BasePresenter {
    
    weak var view: PaywallViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension PaywallPresenter: PaywallViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}
