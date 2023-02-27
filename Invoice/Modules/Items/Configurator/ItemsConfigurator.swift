//
//  ItemsConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation

final class ItemsConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> ItemsViewController {
        let controller: ItemsViewController = ItemsViewController.loadFromNib()
        let presenter = ItemsPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
