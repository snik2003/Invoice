//
//  Onboard1Presenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol Onboard1ViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class Onboard1Presenter: BasePresenter {
    
    weak var view: Onboard1ViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension Onboard1Presenter: Onboard1ViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
}

