//
//  AddInvoiceConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import Foundation

final class AddInvoiceConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule(clients: [ClientModel], items: [ItemModel]) -> AddInvoiceViewController {
        let controller: AddInvoiceViewController = AddInvoiceViewController.loadFromNib()
        let presenter = AddInvoicePresenter(clients: clients, items: items)

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
