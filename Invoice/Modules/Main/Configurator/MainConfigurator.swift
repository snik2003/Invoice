//
//  MainConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation

final class MainConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> MainViewController {
        let controller: MainViewController = MainViewController.loadFromNib()
        let presenter = MainPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
