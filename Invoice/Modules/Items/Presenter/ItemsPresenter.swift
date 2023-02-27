//
//  ItemsPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol ItemsViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class ItemsPresenter: BasePresenter {
    
    weak var view: ItemsViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension ItemsPresenter: ItemsViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}

