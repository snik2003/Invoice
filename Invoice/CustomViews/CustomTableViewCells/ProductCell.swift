//
//  ProductCell.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit
import StoreKit
import ApphudSDK

class ProductCell: BaseTableCell {

    weak var delegate: PaywallViewController?
    var index: Int?
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var freeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setShadow()
    }
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let index = index else { return }
        guard index != delegate.selectedItem else { return }
        
        backView.layer.borderColor = UIColor.appHintColor.cgColor
        backView.layer.borderWidth = 2.0
        
        backView.viewTouched {
            delegate.selectedItem = index
            delegate.tableView.reloadData()
        }
    }
}

extension ProductCell {
    func configure(product: SKProduct, index: Int) {
        self.index = index
        
        self.backView.clipsToBounds = true
        self.backView.layer.cornerRadius = 12
        self.backView.layer.borderWidth = 0.0
        self.backView.layer.borderColor = UIColor.appPrimaryColor.cgColor
        self.backView.backgroundColor = .white
        
        self.titleLabel.text = product.localizedTitle().uppercased()
        self.titleLabel.textColor = .black
        self.titleLabel.font = .appBodyFont
        
        self.priceLabel.text = product.localizedFullPriceText()
        self.priceLabel.textColor = .appHintColor
        self.priceLabel.font = .appSubtitleFont
        
        self.freeLabel.isHidden = true
        self.freeLabel.textColor = .black
        self.freeLabel.font = .appSubtitleFont
        
        if let subscriptionPeriod = product.subscriptionPeriod, let localizedPeriod = subscriptionPeriod.localizedPeriod() {
            titleLabel.text = localizedPeriod.replacingOccurrences(of: "1 ", with: "").uppercased()
            priceLabel.text = (priceLabel.text ?? "") + " / " + localizedPeriod.replacingOccurrences(of: "1 ", with: "")
        } else {
            titleLabel.text = "paywall.screen.product.lifetime.purchase.period.title".localized().uppercased()
        }
        
        if let introductoryPrice = product.introductoryPrice, let trialText = introductoryPrice.localizedTrialPeriod() {
            self.freeLabel.isHidden = false
            self.freeLabel.text = trialText
        }
        
        layoutSubviews()
        
        guard let delegate = delegate, index == delegate.selectedItem else { return }
        backView.layer.borderWidth = 2.0
        layoutSubviews()
    }
    
    private func setShadow() {
        backView.clipsToBounds = false
        backView.layer.shadowColor = UIColor.appHintColor.cgColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backView.layer.shadowOpacity = 0.5
        backView.layer.shadowRadius = 12.0
        backView.layer.masksToBounds = false
    }
}
