//
//  DraftItemInvoiceCell.swift
//  Invoice
//
//  Created by Сергей Никитин on 02.12.2022.
//

import UIKit

class DraftItemInvoiceCell: BaseTableCell {

    weak var delegate: AddInvoiceViewController?
    var index: Int?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var amountLabelCenterConstraint: NSLayoutConstraint!
    
    @IBAction func deleteButtonAction() {
        guard let index = index else { return }
        guard let delegate = delegate else { return }
        guard !delegate.draft.paid else { return }
        
        deleteButton.viewTouched {
            delegate.draft.draftItems.remove(at: index)
            delegate.hasChanges = true
            delegate.reloadData()
            
            delegate.sendButton.isEnabled = delegate.checkButtonsEnabledStatus()
            delegate.previewButton.isEnabled = delegate.checkButtonsEnabledStatus()
        }
    }

    private var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
    
    private var currencySymbol: String {
        let appDataService: AppDataServiceProtocol = serviceLocator.getService()
        return appDataService.currencySymbol
    }
    
    private var zeroValue: String {
        guard let separator = Locale.current.decimalSeparator else { return "0.00" + currencySymbol }
        return  "0" + separator + "00" + currencySymbol
    }
}

extension DraftItemInvoiceCell {
    
    func configure(model: DraftItemModel, index: Int) {
        self.index = index
        
        self.contentView.backgroundColor = .clear
        self.backView.clipsToBounds = true
        self.backView.backgroundColor = .white
        
        self.deleteButton.isEnabled = delegate?.draft.paid == false
        
        self.nameLabel.text = model.name
        self.nameLabel.textColor = .black
        self.nameLabel.font = .appSubtitleFont
        
        self.amountLabel.text = stringAmount(model.amount * Double(model.quantity))
        self.amountLabel.textColor = .black
        self.amountLabel.font = .appSubtitleFont
        self.amountLabelCenterConstraint.constant = 0.0
        
        self.quantityLabel.text = String(model.quantity) + " x " + stringAmount(model.amount)
        self.quantityLabel.textColor = .appHintColor
        self.quantityLabel.font = .appBody2Font
        self.quantityLabel.alpha = 0.0
    
        guard model.quantity > 1 else { return }
        self.amountLabelCenterConstraint.constant = -10.0
        self.quantityLabel.alpha = 1.0
    }
    
    func stringAmount(_ value: Double) -> String {
        guard let string = numberFormatter.string(from: NSNumber(value: value)) else { return zeroValue }
        return string + currencySymbol
    }
}
