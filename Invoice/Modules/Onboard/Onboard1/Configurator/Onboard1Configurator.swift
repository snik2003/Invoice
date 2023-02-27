//
//  Onboard1Configurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation

final class Onboard1Configurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> Onboard1ViewController {
        let controller: Onboard1ViewController = Onboard1ViewController.loadFromNib()
        let presenter = Onboard1Presenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
