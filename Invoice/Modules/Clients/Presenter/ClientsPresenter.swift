//
//  ClientsPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol ClientsViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class ClientsPresenter: BasePresenter {
    
    weak var view: ClientsViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension ClientsPresenter: ClientsViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}


