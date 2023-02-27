//
//  ReportsConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import Foundation

final class ReportsConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule() -> ReportsViewController {
        let controller: ReportsViewController = ReportsViewController.loadFromNib()
        let presenter = ReportsPresenter()

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}

