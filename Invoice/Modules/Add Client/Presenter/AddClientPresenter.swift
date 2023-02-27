//
//  AddClientPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit

protocol AddClientViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class AddClientPresenter: BasePresenter {
    
    weak var view: AddClientViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension AddClientPresenter: AddClientViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}

