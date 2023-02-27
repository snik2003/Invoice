//
//  PaywallViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit
import StoreKit
import ApphudSDK

protocol PaywallViewInput: BaseViewInput {
    func setupInitialState()
}

final class PaywallViewController: BaseViewController {

    var presenter: PaywallViewOutput?
    
    var isOnboard = false
    
    var products: [SKProduct] = Constants.shared.storeProducts
    var selectedItem = -1
    var selectedProduct: ApphudProduct?
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var purchaseButton: PrimaryButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var benefitsCell: UITableViewCell!
    
    @IBOutlet weak var benefitsView: UIView!
    @IBOutlet weak var benefitsLabel: UILabel!
    @IBOutlet weak var benefit1Label: UILabel!
    @IBOutlet weak var benefit2Label: UILabel!
    @IBOutlet weak var benefit3Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        benefitsViewShadow()
    }
    
    @IBAction func closeButtonAction() {
        if isOnboard {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.setupRootViewController()
        } else {
            closeViewControllerAction()
        }
    }
    
    @IBAction func purchaseButtonAction() {
        guard let presenter = presenter else { return }
                
        purchaseButton.viewTouched {
            guard !Constants.shared.isTestMode else {
                presenter.setPremiumMode(true)
                self.setupRootViewController(isOnboard: self.isOnboard)
                return
            }
            
            guard let product = self.selectedProduct else { return }
            
            self.showLoading()
            Apphud.purchase(product) { result in
                self.hideLoading()
                
                if let error = result.error {
                    self.showAttentionMessage(error.localizedDescription)
                } else if let subscription = result.subscription, subscription.isActive() {
                    presenter.setPremiumMode(Apphud.hasActiveSubscription())
                    self.setupRootViewController(isOnboard: self.isOnboard)
                } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                    presenter.setPremiumMode(Apphud.hasActiveSubscription())
                    self.setupRootViewController(isOnboard: self.isOnboard)
                } else {
                    self.showAttentionMessage("paywall.screen.cancel.purchase.message.text".localized())
                }
            }
        }
    }
    
    @IBAction func restoreButtonAction() {
        self.restorePurchases()
    }
    
    @IBAction func termsButtonAction() {
        self.openTermsOfUse()
    }
    
    @IBAction func privacyButtonAction() {
        self.openPrivacyPolicy()
    }
}

extension PaywallViewController: PaywallViewInput {
    
    func setupInitialState() {
        purchaseButton.setTitle("paywall.screen.purchase.button.title".localized(), for: .normal)
        purchaseButton.isEnabled = false
        
        termsButton.setTitle("paywall.screen.terms.of.use.button.title".localized(), for: .normal)
        termsButton.setTitleColor(.appHintColor, for: .normal)
        termsButton.titleLabel?.font = .appBody2Font
        
        restoreButton.setTitle("paywall.screen.restore.button.title".localized(), for: .normal)
        restoreButton.setTitleColor(.appHintColor, for: .normal)
        restoreButton.titleLabel?.font = .appBody2Font
        
        privacyButton.setTitle("paywall.screen.privacy.policy.button.title".localized(), for: .normal)
        privacyButton.setTitleColor(.appHintColor, for: .normal)
        privacyButton.titleLabel?.font = .appBody2Font
        
        titleLabel.text = "paywall.screen.title.label.text".localized()
        titleLabel.textColor = .black
        titleLabel.font = .appTitleFont
        
        benefitsView.clipsToBounds = true
        benefitsView.layer.cornerRadius = 12
        benefitsView.backgroundColor = .white
        
        benefitsLabel.text = "paywall.screen.benefits.label.text".localized()
        benefitsLabel.textColor = .black
        benefitsLabel.font = .appSubtitleFont
        
        benefit1Label.text = "paywall.screen.benefit1.label.text".localized()
        benefit1Label.textColor = .black
        benefit1Label.font = .appSubtitleFont
        
        benefit2Label.text = "paywall.screen.benefit2.label.text".localized()
        benefit2Label.textColor = .black
        benefit2Label.font = .appSubtitleFont
        
        benefit3Label.text = "paywall.screen.benefit3.label.text".localized()
        benefit3Label.textColor = .black
        benefit3Label.font = .appSubtitleFont
        
        guard products.count > 0 else { return }
        selectedItem = 0
        purchaseButton.isEnabled = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProductCell.self)
        tableView.reloadData()
    }
    
    private func benefitsViewShadow() {
        benefitsView.clipsToBounds = false
        benefitsView.layer.shadowColor = UIColor.appHintColor.cgColor
        benefitsView.layer.shadowOffset = CGSize(width: 0, height: 0)
        benefitsView.layer.shadowOpacity = 0.5
        benefitsView.layer.shadowRadius = 12.0
        benefitsView.layer.masksToBounds = false
    }
}

extension PaywallViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return products.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 232
        case 1:
            return 92
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return benefitsCell
        case 1:
            let cell: ProductCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            cell.configure(product: products[indexPath.row], index: indexPath.row)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
