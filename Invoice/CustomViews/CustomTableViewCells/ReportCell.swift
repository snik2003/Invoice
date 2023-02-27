//
//  ReportCell.swift
//  Invoice
//
//  Created by Сергей Никитин on 02.12.2022.
//

import UIKit

class ReportCell: BaseTableCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var clientsLabel: UILabel!
    @IBOutlet weak var invoicesLabel: UILabel!
    
}

extension ReportCell {
    
    func configure(title: String, clientCount: Int, invoicesCount: Int, paidAmount: String, year: Bool = false) {
        self.backgroundColor = .white
        
        titleLabel.text = title
        titleLabel.alpha = 1.0
        titleLabel.textColor = .black
        titleLabel.font = year ? .appBodyFont : .appSubtitleFont
        
        amountLabel.text = paidAmount
        amountLabel.alpha = 1.0
        amountLabel.textColor = .black
        amountLabel.font = year ? .appBodyFont : .appSubtitleFont
        
        clientsLabel.text = String(clientCount)
        clientsLabel.alpha = 1.0
        clientsLabel.textColor = .black
        clientsLabel.font = year ? .appBodyFont : .appSubtitleFont
        
        invoicesLabel.text = String(invoicesCount)
        invoicesLabel.alpha = 1.0
        invoicesLabel.textColor = .black
        invoicesLabel.font = year ? .appBodyFont : .appSubtitleFont
        
    }
    
    func configureHeader() {
        self.backgroundColor = .white
        
        titleLabel.text = ""
        titleLabel.alpha = 0.0
        titleLabel.textColor = .black
        titleLabel.font = .appSubtitleFont
        
        amountLabel.text = "reports.screen.paid.amount.label.text".localized()
        amountLabel.alpha = 1.0
        amountLabel.textColor = .black
        amountLabel.font = .appSubtitleFont
        
        clientsLabel.text = "reports.screen.clients.count.label.text".localized()
        clientsLabel.alpha = 1.0
        clientsLabel.textColor = .black
        clientsLabel.font = .appSubtitleFont
        
        invoicesLabel.text = "reports.screen.invoices.count.label.text".localized()
        invoicesLabel.alpha = 1.0
        invoicesLabel.textColor = .black
        invoicesLabel.font = .appSubtitleFont
    }
    
    func configureEmpty() {
        self.backgroundColor = .white
        
        titleLabel.alpha = 0.0
        amountLabel.alpha = 0.0
        clientsLabel.alpha = 0.0
        invoicesLabel.alpha = 0.0
    }
}
