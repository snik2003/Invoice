//
//  ItemsListPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//

import UIKit

protocol ItemsListViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class ItemsListPresenter: BasePresenter {
    
    weak var view: ItemsListViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension ItemsListPresenter: ItemsListViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}
