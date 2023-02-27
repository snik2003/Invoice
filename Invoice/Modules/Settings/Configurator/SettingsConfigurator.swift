//
//  SettingsConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation

final class SettingsConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> SettingsViewController {
        let controller: SettingsViewController = SettingsViewController.loadFromNib()
        let presenter = SettingsPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}

