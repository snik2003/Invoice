//
//  PreviewPresenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 05.12.2022.
//

import UIKit

protocol PreviewViewOutput: BaseViewOutput {
    func viewLoaded()
}

final class PreviewPresenter: BasePresenter {
    
    weak var view: PreviewViewInput?
    private var appDataService: AppDataServiceProtocol
    private var invoice: InvoiceModel
    private var data: NSData
    private var url: URL
    
    init(invoice: InvoiceModel, data: NSData, url: URL, appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
        self.invoice = invoice
        self.data = data
        self.url = url
    }
}

extension PreviewPresenter: PreviewViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState(invoice: self.invoice, data: self.data, url: self.url)
    }
}
