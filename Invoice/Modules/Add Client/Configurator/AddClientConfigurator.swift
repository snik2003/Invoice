//
//  AddClientConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import Foundation

final class AddClientConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> AddClientViewController {
        let controller: AddClientViewController = AddClientViewController.loadFromNib()
        let presenter = AddClientPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}

