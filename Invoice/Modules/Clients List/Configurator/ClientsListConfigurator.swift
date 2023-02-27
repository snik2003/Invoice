//
//  ClientsListConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import Foundation

final class ClientsListConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> ClientsListViewController {
        let controller: ClientsListViewController = ClientsListViewController.loadFromNib()
        let presenter = ClientsListPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}

