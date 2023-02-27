//
//  AddItemConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//

import Foundation

final class AddItemConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> AddItemViewController {
        let controller: AddItemViewController = AddItemViewController.loadFromNib()
        let presenter = AddItemPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
