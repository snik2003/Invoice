//
//  Onboard2Configurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation

final class Onboard2Configurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> Onboard2ViewController {
        let controller: Onboard2ViewController = Onboard2ViewController.loadFromNib()
        let presenter = Onboard2Presenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}
