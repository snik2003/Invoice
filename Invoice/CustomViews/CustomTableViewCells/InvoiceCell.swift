//
//  InvoiceCell.swift
//  Invoice
//
//  Created by Сергей Никитин on 01.12.2022.
//

import UIKit

class InvoiceCell: BaseTableCell {

    weak var delegate: MainViewController?
    var model: InvoiceModel?
    var index: Int?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var paidDateLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviews()
    }
    
    @IBAction func editButtonAction() {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        backView.viewTouched {
            delegate.openInvoice(model)
        }
    }
    
    @IBAction func menuButtonAction() {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        delegate.openMenu(for: model)
    }
}

extension InvoiceCell {
    
    func configure(model: InvoiceModel, client: ClientModel?, index: Int) {
        self.model = model
        self.index = index
        
        self.backView.clipsToBounds = true
        self.backView.backgroundColor = .white
        
        self.separator.alpha = 1.0
        
        nameLabel.text = client?.name
        nameLabel.textColor = .black
        nameLabel.font = .appSubtitleFont
        
        numberLabel.text = model.invoiceString
        numberLabel.textColor = .appHintColor
        numberLabel.font = .appBody2Font
        
        dateLabel.text = delegate?.presenter?.stringDate(model.issueDate)
        dateLabel.textColor = .appHintColor
        dateLabel.font = .appBody2Font
        
        amountLabel.text = delegate?.presenter?.stringAmount(model.total)
        amountLabel.textColor = .black
        amountLabel.font = .appSubtitleFont
        
        statusLabel.text = model.status
        statusLabel.textColor = .appHintColor
        statusLabel.font = .appBody2Font
        
        paidDateLabel.text = "Due " + (delegate?.presenter?.stringDate(model.dueDate) ?? "")
        paidDateLabel.textColor = .appHintColor
        paidDateLabel.font = .appBody2Font
        paidDateLabel.alpha = 1.0
        
        if let paidDate = model.paidDate {
            statusLabel.textColor = .appPrimaryColor
            paidDateLabel.textColor = .appPrimaryColor
            paidDateLabel.text = delegate?.presenter?.stringDate(paidDate)
            paidDateLabel.alpha = 1.0
        } else if Date() > model.dueDate {
            statusLabel.textColor = .systemRed
            paidDateLabel.textColor = .systemRed
            paidDateLabel.text = delegate?.presenter?.stringDate(model.dueDate)
            paidDateLabel.alpha = 1.0
        }
        
        self.layoutSubviews()
    }
    
    private func updateSubviews() {
        backView.roundCorners(corners: .allCorners, radius: 0.0)
        guard let delegate = delegate, let index = index else { return }
        
        if index == 0 && delegate.dataSource.count == 1 {
            self.backView.roundCorners(corners: .allCorners, radius: 12.0)
            self.separator.alpha = 0.0
        } else if index == 0 {
            self.backView.roundCorners(corners: [.topLeft,.topRight], radius: 12.0)
            self.separator.alpha = 1.0
        } else if index == delegate.dataSource.count - 1 {
            self.backView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 12.0)
            self.separator.alpha = 0.0
        }
    }
}
