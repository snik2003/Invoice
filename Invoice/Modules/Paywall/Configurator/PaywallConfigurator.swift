//
//  PaywallConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation

final class PaywallConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> PaywallViewController {
        let controller: PaywallViewController = PaywallViewController.loadFromNib()
        let presenter = PaywallPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
