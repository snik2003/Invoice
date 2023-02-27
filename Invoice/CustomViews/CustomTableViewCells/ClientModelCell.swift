//
//  ClientModelCell.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit

class ClientModelCell: BaseTableCell {

    weak var delegate: BaseViewController?
    var model: ClientModel?
    var index: Int?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var separator: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviews()
    }
    
    @IBAction func buttonAction() {
        guard let model = model else { return }
        
        if let delegate = delegate as? ClientsViewController {
            label.viewTouched {
                delegate.openClient(model)
            }
        } else if let delegate = delegate as? ClientsListViewController, let controller = delegate.delegate as? AddInvoiceViewController {
            controller.draft.client = model
            controller.hasChanges = true
            delegate.navigationController?.popToViewController(controller, animated: true)
        }
    }
    
}

extension ClientModelCell {
    
    func configure(model: ClientModel, index: Int) {
        self.model = model
        self.index = index
        
        self.backView.clipsToBounds = true
        self.backView.backgroundColor = .white
        
        self.label.text = model.name
        self.label.textColor = .black
        self.label.font = .appSubtitleFont
        
        self.separator.alpha = 1.0
        self.layoutSubviews()
    }
    
    private func updateSubviews() {
        self.backView.roundCorners(corners: .allCorners, radius: 0.0)
        guard let index = index else { return }
        
        if let delegate = delegate as? ClientsViewController {
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
        } else if let delegate = delegate as? ClientsListViewController {
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
}
