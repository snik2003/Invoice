//
//  ItemModelCell.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//

import UIKit

class ItemModelCell: BaseTableCell {

    weak var delegate: BaseViewController?
    var model: ItemModel?
    var index: Int?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    @IBOutlet weak var amountLabelCenterConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviews()
    }
    
    @IBAction func buttonAction() {
        guard let model = model else { return }
        
        if let delegate = delegate as? ItemsViewController {
            nameLabel.viewTouched {
                delegate.openItem(model)
            }
        } else if let delegate = delegate as? ItemsListViewController, let controller = delegate.delegate as? AddInvoiceViewController {
            controller.draft.items.append(model)
            controller.hasChanges = true
            delegate.navigationController?.popToViewController(controller, animated: true)
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
        return "0" + separator + "00" + currencySymbol
    }
}

extension ItemModelCell {
    
    func configure(model: ItemModel, index: Int) {
        self.model = model
        self.index = index
        
        self.backView.clipsToBounds = true
        self.backView.backgroundColor = .white
        
        self.nameLabel.text = model.name
        self.nameLabel.textColor = .black
        self.nameLabel.font = .appSubtitleFont
        
        self.amountLabel.text = stringAmount(model.amount * Double(model.quantity))
        self.amountLabel.textColor = .black
        self.amountLabel.font = .appSubtitleFont
        self.amountLabelCenterConstraint.constant = model.discount > 0 ? -8 : 0
        
        self.discountLabel.text = "Discount: -" + stringAmount(model.discount * Double(model.quantity))
        self.discountLabel.textColor = .appHintColor
        self.discountLabel.font = .appCaptionFont
        self.discountLabel.alpha = model.discount > 0 ? 1.0 : 0.0
        
        self.separator.alpha = 1.0
        self.layoutSubviews()
    }
    
    private func updateSubviews() {
        self.backView.roundCorners(corners: .allCorners, radius: 0.0)
        guard let index = index else { return }
    
        if let delegate = delegate as? ItemsViewController {
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
        } else if let delegate = delegate as? ItemsListViewController {
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
    
    private func stringAmount(_ value: Double) -> String {
        guard let string = numberFormatter.string(from: NSNumber(value: value)) else { return zeroValue }
        return string + currencySymbol
    }
}
