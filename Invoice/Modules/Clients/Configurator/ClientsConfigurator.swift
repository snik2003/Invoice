//
//  ClientsConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation

final class ClientsConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> ClientsViewController {
        let controller: ClientsViewController = ClientsViewController.loadFromNib()
        let presenter = ClientsPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}

