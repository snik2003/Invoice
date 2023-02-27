//
//  ItemsListConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//

import Foundation

final class ItemsListConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> ItemsListViewController {
        let controller: ItemsListViewController = ItemsListViewController.loadFromNib()
        let presenter = ItemsListPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
