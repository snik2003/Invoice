//
//  AddItemViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 30.11.2022.
//

import UIKit

protocol AddItemViewInput: BaseViewInput {
    func setupInitialState()
}

class AddItemViewController: BaseViewController {

    var presenter: AddItemViewOutput?
    
    var delegate: BaseViewController?
    var item: ItemModel?
    
    var price: Double = 0.0
    var quantity: Int = 1
    
    var discountType: DiscountModel = .percentage
    var discountValue: Double = 0.0
    
    var taxable = false
    var taxType: TaxModel = .onTotal
    var taxValue: Double = 20.0
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: PrimaryButton!

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountTypeLabel: UILabel!
    @IBOutlet weak var discountValueLabel: UILabel!
    
    @IBOutlet weak var discountButton: UIButton!
    @IBOutlet weak var discountTextField: UITextField!
    
    @IBOutlet weak var taxView: UIView!
    @IBOutlet weak var taxableLabel: UILabel!
    @IBOutlet weak var taxTypeLabel: UILabel!
    @IBOutlet weak var taxRateLabel: UILabel!
    
    @IBOutlet weak var taxSeparator: UIView!
    @IBOutlet weak var taxSeparator2: UIView!
    @IBOutlet weak var taxViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var taxTextField: UITextField!
    @IBOutlet weak var taxableSwitch: UISwitch!
    @IBOutlet weak var taxButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    @IBAction func backButtonAction() {
        hideKeyboard()
        backButton.viewTouched {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonAction() {
        guard let presenter = presenter else { return }
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        hideKeyboard()
        saveButton.viewTouched {
            if !presenter.isPremium() && presenter.itemsCount() >= Constants.shared.freeModeMaxitems {
                self.openPaywall()
                return
            }
            
            if let item = self.item {
                self.showLoading()
                ItemModel.updateItem(item, name: name, amount: self.price, quantity: self.quantity,
                                     discountType: self.discountType, discount: self.discountValue,
                                     taxable: self.taxable, tax: self.taxValue, taxType: self.taxType) { _ in
                    self.hideLoading()
                    self.navigationController?.popViewController(animated: true)
                }
                
                return
            }
                
            self.showLoading()
            ItemModel.addItem(name, amount: self.price, quantity: self.quantity,
                              discountType: self.discountType, discount: self.discountValue,
                              taxable: self.taxable, tax: self.taxValue, taxType: self.taxType) { model in
                
                if let model = model, let controller = self.delegate as? AddInvoiceViewController {
                    controller.draft.items.append(model)
                    controller.items.append(model)
                    controller.hasChanges = true
                    self.hideLoading()
                    self.navigationController?.popToViewController(controller, animated: true)
                    return
                }
                
                self.hideLoading()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func discountButtonAction() {
        guard let presenter = presenter else { return }
        
        showDiscountForm(onCancel: nil, onPercentage: {
            self.discountType = .percentage
            self.discountButton.setTitle(self.discountType.title, for: .normal)
            self.discountValue = min(self.discountValue, 100)
            self.discountTextField.text = presenter.stringPercent(self.discountValue)
            self.saveButton.isEnabled = self.checkEnableStatusSaveButton()
        }, onFixed: {
            self.discountType = .fixed
            self.discountButton.setTitle(self.discountType.title, for: .normal)
            self.discountTextField.text = presenter.stringAmount(self.discountValue)
            self.saveButton.isEnabled = self.checkEnableStatusSaveButton()
        })
    }
    
    @IBAction func taxButtonAction() {
        showTaxForm(onCancel: nil, onTotal: {
            self.taxType = .onTotal
            self.taxButton.setTitle(self.taxType.title, for: .normal)
            self.saveButton.isEnabled = self.checkEnableStatusSaveButton()
        }, onDeducted: {
            self.taxType = .deducted
            self.taxButton.setTitle(self.taxType.title, for: .normal)
            self.saveButton.isEnabled = self.checkEnableStatusSaveButton()
        })
    }
    
    @IBAction func taxableSwitchOnChange(sender: UISwitch) {
        taxable = sender.isOn
        setupTaxView()
    }
}

extension AddItemViewController: AddItemViewInput {
    func setupInitialState() {
        guard let presenter = presenter else { return }
        
        taxable = presenter.taxable()
        taxType = presenter.taxType()
        taxValue = presenter.taxValue()
        
        backButton.setTitle("add.item.screen.header.label.text".localized(), for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = .appTitleFont
        
        saveButton.setTitle("add.item.screen.save.button.title".localized(), for: .normal)
        saveButton.isEnabled = false
        
        nameView.clipsToBounds = true
        nameView.layer.cornerRadius = 12
        nameView.backgroundColor = .white
        
        nameLabel.text = "add.item.screen.name.label.text".localized()
        nameLabel.textColor = .black
        nameLabel.font = .appSubtitleFont
        
        amountLabel.text = "add.item.screen.amount.label.text".localized()
        amountLabel.textColor = .black
        amountLabel.font = .appSubtitleFont
        
        quantityLabel.text = "add.item.screen.quantity.label.text".localized()
        quantityLabel.textColor = .black
        quantityLabel.font = .appSubtitleFont
        
        nameTextField.placeholder = "add.item.screen.name.label.text".localized()
        amountTextField.placeholder = "add.item.screen.amount.label.text".localized()
        quantityTextField.placeholder = "add.item.screen.quantity.label.text".localized()
        
        setupTextField(nameTextField)
        setupTextField(amountTextField)
        setupTextField(quantityTextField)
        
        amountTextField.text = presenter.stringAmount(price)
        quantityTextField.text = String(quantity)
        
        discountView.clipsToBounds = true
        discountView.layer.cornerRadius = 12
        discountView.backgroundColor = .white
        
        taxView.clipsToBounds = true
        taxView.layer.cornerRadius = 12
        taxView.backgroundColor = .white
        setupTaxView(animated: false)
        
        discountTypeLabel.text = "add.item.screen.discount.type.label.text".localized()
        discountTypeLabel.textColor = .black
        discountTypeLabel.font = .appSubtitleFont
        
        discountValueLabel.text = "add.item.screen.discount.value.label.text".localized()
        discountValueLabel.textColor = .black
        discountValueLabel.font = .appSubtitleFont
        
        taxableLabel.text = "add.item.screen.taxable.label.text".localized()
        taxableLabel.textColor = .black
        taxableLabel.font = .appSubtitleFont
        
        taxTypeLabel.text = "add.item.screen.tax.type.label.text".localized()
        taxTypeLabel.textColor = .black
        taxTypeLabel.font = .appSubtitleFont
        
        taxRateLabel.text = "add.item.screen.tax.rate.label.text".localized()
        taxRateLabel.textColor = .black
        taxRateLabel.font = .appSubtitleFont
        
        discountButton.setTitle(discountType.title, for: .normal)
        discountButton.setTitleColor(.appPrimaryColor, for: .normal)
        discountButton.titleLabel?.font = .appSubtitleFont
        
        taxButton.setTitle(taxType.title, for: .normal)
        taxButton.setTitleColor(.appPrimaryColor, for: .normal)
        taxButton.titleLabel?.font = .appSubtitleFont
        
        taxableSwitch.onTintColor = .appPrimaryColor
        taxableSwitch.isOn = taxable
        
        discountTextField.placeholder = "add.item.screen.discount.value.label.text".localized()
        setupTextField(discountTextField)
        discountTextField.text = presenter.stringPercent(discountValue)
        
        taxTextField.placeholder = "add.item.screen.discount.value.label.text".localized()
        setupTextField(taxTextField)
        taxTextField.text = presenter.stringPercent(taxValue)
        
        if let item = self.item {
            backButton.setTitle("add.item.screen.edit.header.label.text".localized(), for: .normal)
            saveButton.isEnabled = true
            
            price = item.amount
            quantity = Int(item.quantity)
            
            discountType = DiscountModel.getDiscountModel(from: Int(item.discountType)) ?? .percentage
            discountValue = item.discountValue
            
            taxType = TaxModel.getTaxModel(from: Int(item.taxType)) ?? .onTotal
            taxable = item.taxable
            taxValue = item.taxValue
            
            
            nameTextField.text = item.name
            amountTextField.text = presenter.stringAmount(item.amount)
            quantityTextField.text = String(item.quantity)
            
            discountTextField.text = presenter.stringPercent(item.discountValue)
            
            if let discount = DiscountModel.getDiscountModel(from: Int(item.discountType)) {
                discountButton.setTitle(discount.title, for: .normal)
                discountTextField.text = discount == .percentage ? presenter.stringPercent(item.discountValue) : presenter.stringAmount(item.discountValue)
            }
            
            taxableSwitch.isOn = taxable
            taxTextField.text = presenter.stringPercent(taxValue)
            setupTaxView(animated: false)
            
            if let taxType = TaxModel.getTaxModel(from: Int(item.taxType)) {
                taxButton.setTitle(taxType.title, for: .normal)
            }
        }
    }
    
    func setupTextField(_ textField: UITextField) {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.appHintColor, .font : UIFont.appSubtitleFont]
        
        textField.backgroundColor = .clear
        textField.text = nil
        textField.textColor = .black
        textField.tintColor = .black
        textField.font = .appSubtitleFont
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: attributes)
        textField.delegate = self
    }
    
    func setupTaxView(animated: Bool = true, completion: EmptyBlock? = nil) {
        guard animated else {
            taxSeparator.alpha = taxable ? 1.0 : 0.0
            taxSeparator2.alpha = taxable ? 1.0 : 0.0
            taxTypeLabel.alpha = taxable ? 1.0 : 0.0
            taxRateLabel.alpha = taxable ? 1.0 : 0.0
            taxTextField.alpha = taxable ? 1.0 : 0.0
            taxButton.alpha = taxable ? 1.0 : 0.0
            taxViewHeightConstraint.constant = taxable ? 156 : 52
            completion?()
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.taxSeparator.alpha = self.taxable ? 1.0 : 0.0
            self.taxSeparator2.alpha = self.taxable ? 1.0 : 0.0
            self.taxTypeLabel.alpha = self.taxable ? 1.0 : 0.0
            self.taxRateLabel.alpha = self.taxable ? 1.0 : 0.0
            self.taxTextField.alpha = self.taxable ? 1.0 : 0.0
            self.taxButton.alpha = self.taxable ? 1.0 : 0.0
            self.taxViewHeightConstraint.constant = self.taxable ? 156 : 52
            self.view.layoutSubviews()
        }, completion: { _ in
            completion?()
        })
    }
    
    func checkEnableStatusSaveButton() -> Bool {
        guard let name = nameTextField.text, !name.isEmpty else { return false }
        guard price > 0 else { return false }
        guard quantity > 0 else { return false }
        
        var total = price - discountValue
        if discountType == .percentage { total = price - discountValue * price / 100 }
        guard total > 0 else { return false }
        
        return true
    }
    
    func showDiscountForm(onCancel: EmptyBlock? = nil, onPercentage: EmptyBlock? = nil, onFixed: EmptyBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = onCancel
        
        form.dopButton1Title = DiscountModel.fixed.title
        form.dopButton1Completion = onFixed
        form.dopButton2Title = DiscountModel.percentage.title
        form.dopButton2Completion = onPercentage
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
    
    func showTaxForm(onCancel: EmptyBlock? = nil, onTotal: EmptyBlock? = nil, onDeducted: EmptyBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = onCancel
        
        form.dopButton1Title = TaxModel.deducted.title
        form.dopButton1Completion = onDeducted
        form.dopButton2Title = TaxModel.onTotal.title
        form.dopButton2Completion = onTotal
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
}

extension AddItemViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        
        if textField == nameTextField { return }
        guard var text = textField.text else { return }
        
        let currentSymbol = presenter?.currencySymbol() ?? "$"
        text = text.replacingOccurrences(of: currentSymbol, with: "")
        text = text.replacingOccurrences(of: "%", with: "")
        text = text.replacingOccurrences(of: ",", with: ".")
        textField.text = text
        
        guard let value = Double(text) else { return }
        textField.text = presenter?.stringDouble(value) ?? "0"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            saveButton.isEnabled = checkEnableStatusSaveButton()
            return
        }
        
        guard var text = textField.text, let presenter = presenter else {
            saveButton.isEnabled = checkEnableStatusSaveButton()
            return
        }
        
        if text.isEmpty { text = "0" }
        
        if textField == amountTextField {
            price = Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            textField.text = presenter.stringAmount(price)
        }
        
        if textField == quantityTextField {
            quantity = Int(text) ?? 0
            textField.text = String(quantity)
        }
        
        if textField == discountTextField {
            discountValue = Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            textField.text = discountType == .percentage ? presenter.stringPercent(discountValue) : presenter.stringAmount(discountValue)
        }
        
        if textField == taxTextField {
            taxValue = Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            textField.text = presenter.stringPercent(taxValue)
        }
        
        saveButton.isEnabled = checkEnableStatusSaveButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            amountTextField.becomeFirstResponder()
        } else if textField == amountTextField {
            quantityTextField.becomeFirstResponder()
        } else if textField == quantityTextField {
            hideKeyboard()
        }
        
        saveButton.isEnabled = checkEnableStatusSaveButton()
        return true
    }
}
