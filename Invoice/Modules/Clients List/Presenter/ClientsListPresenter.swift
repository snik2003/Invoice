//
//  ClientsListPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit

protocol ClientsListViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class ClientsListPresenter: BasePresenter {
    
    weak var view: ClientsListViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension ClientsListPresenter: ClientsListViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}

