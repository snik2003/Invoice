//
//  PreviewConfigurator.swift
//  Invoice
//
//  Created by Сергей Никитин on 05.12.2022.
//

import Foundation

final class PreviewConfigurator {

    // MARK: - Instantiate module
    static func instantiateModule(invoice: InvoiceModel, data: NSData, url: URL) -> PreviewViewController {
        let controller: PreviewViewController = PreviewViewController.loadFromNib()
        let presenter = PreviewPresenter(invoice: invoice, data: data, url: url)

        presenter.view = controller
        controller.presenter = presenter

        return controller
    }
}

