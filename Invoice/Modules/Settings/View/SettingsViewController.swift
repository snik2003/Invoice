//
//  SettingsViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol SettingsViewInput: BaseViewInput {
    func setupInitialState()
}

class SettingsViewController: BaseViewController {

    var presenter: SettingsViewOutput?
    
    var firstAppear = true
    
    var picker = UIPickerView()
    var pickerDataSource: [String] = []
    var currencyNames: [String: String] = [:]
    
    var toolbar = UIToolbar()
    var toolbarLabel = UILabel()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blockView: UIView!
    
    @IBOutlet var premiumCell: UITableViewCell!
    @IBOutlet weak var premiumButton: SecondaryButton!
    
    @IBOutlet var businessCell: UITableViewCell!
    @IBOutlet weak var businessHeaderLabel: UILabel!
    @IBOutlet weak var businessView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet var currencyCell: UITableViewCell!
    @IBOutlet weak var currencyHeaderLabel: UILabel!
    @IBOutlet weak var currencyView: UIView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyNameValueLabel: UILabel!
    @IBOutlet weak var currencyNameButton: UIButton!
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var currencySymbolValueLabel: UILabel!
    
    @IBOutlet var taxCell: UITableViewCell!
    @IBOutlet weak var taxHeaderLabel: UILabel!
    @IBOutlet weak var taxView: UIView!
    @IBOutlet weak var taxableLabel: UILabel!
    @IBOutlet weak var taxTypeLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    
    @IBOutlet weak var taxButton: UIButton!
    @IBOutlet weak var taxableSwitch: UISwitch!
    @IBOutlet weak var taxTextField: UITextField!
    
    @IBOutlet var buttonsCell: UITableViewCell!
    @IBOutlet weak var buttonsHeaderLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var developerButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setViewsShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    @IBAction func premiumButtonAction() {
        premiumButton.viewTouched {
            self.openPaywall()
        }
    }
    
    @IBAction func developerButtonAction() {
        developerButton.viewTouched {
            self.openContactDeveloperModule()
        }
    }
    
    @IBAction func privacyButtonAction() {
        privacyButton.viewTouched {
            self.openPrivacyPolicy()
        }
    }
    
    @IBAction func termsButtonAction() {
        termsButton.viewTouched {
            self.openTermsOfUse()
        }
    }
    
    @IBAction func taxButtonAction() {
        showTaxForm(onTotal: {
            self.taxButton.setTitle(TaxModel.onTotal.title, for: .normal)
            self.presenter?.setTaxType(TaxModel.onTotal)
        }, onDeducted: {
            self.taxButton.setTitle(TaxModel.deducted.title, for: .normal)
            self.presenter?.setTaxType(TaxModel.deducted)
        })
    }
    
    @IBAction func taxableSwitchOnChange(sender: UISwitch) {
        presenter?.setTaxable(sender.isOn)
    }
    
    @IBAction func currencyNameButtonAction() {
        guard let presenter = presenter else { return }
        
        currencyNameValueLabel.viewTouched {
            self.picker.reloadAllComponents()
            
            if let index = self.pickerDataSource.firstIndex(where: { $0.lowercased() == presenter.currencyName().lowercased() }) {
                self.picker.selectRow(index, inComponent: 0, animated: false)
            }
            
            self.showPicker()
        }
    }
    
    @objc func toolbarCancelAction() {
        hidePicker()
    }
    
    @objc func toolbarDoneAction() {
        
        let row = picker.selectedRow(inComponent: 0)
        
        let country = pickerDataSource[row]
        if let symbol = currencyNames[country] {
            presenter?.setCurrencyName(country)
            presenter?.setCurrencySymbol(symbol)
        
            currencyNameValueLabel.text = country
            currencySymbolValueLabel.text = symbol
        }
        
        hidePicker()
    }
}

extension SettingsViewController: SettingsViewInput {
    func setupInitialState() {
        titleLabel.text = "main.screen.tabbar5.title".localized()
        titleLabel.textColor = .black
        titleLabel.font = .appTitleFont
        
        premiumButton.setTitle("setting.screen.premium.button.title".localized(), for: .normal)
        premiumButton.titleLabel?.font = .appButtonFont3
        
        businessView.clipsToBounds = true
        businessView.layer.cornerRadius = 12.0
        businessView.backgroundColor = .white
        
        businessHeaderLabel.text = "setting.screen.business.header.label.text".localized()
        businessHeaderLabel.textColor = .appHintColor
        businessHeaderLabel.font = .appCaptionFont
        
        nameLabel.text = "setting.screen.business.name.label.text".localized()
        nameLabel.textColor = .black
        nameLabel.font = .appSubtitleFont
        
        numberLabel.text = "setting.screen.business.number.label.text".localized()
        numberLabel.textColor = .black
        numberLabel.font = .appSubtitleFont
        
        emailLabel.text = "setting.screen.business.email.label.text".localized()
        emailLabel.textColor = .black
        emailLabel.font = .appSubtitleFont
        
        phoneLabel.text = "setting.screen.business.phone.label.text".localized()
        phoneLabel.textColor = .black
        phoneLabel.font = .appSubtitleFont
        
        websiteLabel.text = "setting.screen.business.website.label.text".localized()
        websiteLabel.textColor = .black
        websiteLabel.font = .appSubtitleFont
        
        addressLabel.text = "setting.screen.business.address.label.text".localized()
        addressLabel.textColor = .black
        addressLabel.font = .appSubtitleFont
        
        nameTextField.placeholder = "setting.screen.business.name.label.text".localized()
        setupTextField(nameTextField)
        
        numberTextField.placeholder = "setting.screen.business.number.label.text".localized()
        setupTextField(numberTextField)
        
        emailTextField.placeholder = "setting.screen.business.email.label.text".localized()
        setupTextField(emailTextField)
        
        phoneTextField.placeholder = "setting.screen.business.phone.label.text".localized()
        setupTextField(phoneTextField)
        
        websiteTextField.placeholder = "setting.screen.business.website.label.text".localized()
        setupTextField(websiteTextField)
        
        addressTextField.placeholder = "setting.screen.business.address.label.text".localized()
        setupTextField(addressTextField)
        
        currencyView.clipsToBounds = true
        currencyView.layer.cornerRadius = 12.0
        currencyView.backgroundColor = .white
        
        currencyHeaderLabel.text = "setting.screen.currency.header.label.text".localized()
        currencyHeaderLabel.textColor = .appHintColor
        currencyHeaderLabel.font = .appCaptionFont
        
        currencyNameLabel.text = "setting.screen.currency.name.label.text".localized()
        currencyNameLabel.textColor = .black
        currencyNameLabel.font = .appSubtitleFont
        
        currencySymbolLabel.text = "setting.screen.currency.symbol.label.text".localized()
        currencySymbolLabel.textColor = .black
        currencySymbolLabel.font = .appSubtitleFont
        
        currencyNameValueLabel.text = presenter?.currencyName()
        currencyNameValueLabel.textColor = .appPrimaryColor
        currencyNameValueLabel.font = .appBody2Font
        
        currencySymbolValueLabel.text = presenter?.currencySymbol()
        currencySymbolValueLabel.textColor = .black
        currencySymbolValueLabel.font = .appBody2Font
        
        taxView.clipsToBounds = true
        taxView.layer.cornerRadius = 12.0
        taxView.backgroundColor = .white
        
        taxHeaderLabel.text = "setting.screen.tax.header.label.text".localized()
        taxHeaderLabel.textColor = .appHintColor
        taxHeaderLabel.font = .appCaptionFont
        
        taxableLabel.text = "add.item.screen.taxable.label.text".localized()
        taxableLabel.textColor = .black
        taxableLabel.font = .appSubtitleFont
        
        taxableSwitch.onTintColor = .appPrimaryColor
        taxableSwitch.isOn = presenter?.taxable() ?? false
        
        taxTypeLabel.text = "add.item.screen.tax.type.label.text".localized()
        taxTypeLabel.textColor = .black
        taxTypeLabel.font = .appSubtitleFont
        
        let taxType = presenter?.taxType() ?? .onTotal
        taxButton.setTitle(taxType.title, for: .normal)
        taxButton.setTitleColor(.appPrimaryColor, for: .normal)
        taxButton.titleLabel?.font = .appBody2Font
        
        taxLabel.text = "setting.screen.default.tax.rate.label.text".localized()
        taxLabel.textColor = .black
        taxLabel.font = .appSubtitleFont
        
        taxTextField.placeholder = "setting.screen.default.tax.rate.label.text".localized()
        setupTextField(taxTextField)
        
        buttonsView.clipsToBounds = true
        buttonsView.layer.cornerRadius = 12.0
        buttonsView.backgroundColor = .white
        
        buttonsHeaderLabel.text = "setting.screen.buttons.header.label.text".localized()
        buttonsHeaderLabel.textColor = .appHintColor
        buttonsHeaderLabel.font = .appCaptionFont
        
        developerButton.setTitle("setting.screen.contact.developer.button.title".localized(), for: .normal)
        developerButton.setTitleColor(.appPrimaryColor, for: .normal)
        developerButton.titleLabel?.font = .appButtonFont3
        
        privacyButton.setTitle("setting.screen.privacy.policy.button.title".localized(), for: .normal)
        privacyButton.setTitleColor(.appPrimaryColor, for: .normal)
        privacyButton.titleLabel?.font = .appButtonFont3
        
        termsButton.setTitle("setting.screen.terms.of.use.button.title".localized(), for: .normal)
        termsButton.setTitleColor(.appPrimaryColor, for: .normal)
        termsButton.titleLabel?.font = .appButtonFont3
        
        setupPicker()
        setupToolbar()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func reloadData() {
        guard let presenter = presenter else { return }
        
        nameTextField.text = presenter.bussinessName()
        numberTextField.text = presenter.bussinessNumber()
        emailTextField.text = presenter.bussinessEmail()
        phoneTextField.text = presenter.bussinessPhone()
        websiteTextField.text = presenter.bussinessWebsite()
        addressTextField.text = presenter.bussinessAddress()
        
        let taxValue = presenter.taxValue()
        taxTextField.text = presenter.stringPercent(taxValue)
        
        tableView.reloadData()
    }
    
    func setupTextField(_ textField: UITextField) {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.appHintColor, .font : UIFont.appSubtitleFont]
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: attributes)
        
        textField.backgroundColor = .clear
        textField.tintColor = .black
        textField.font = .appBody2Font
        textField.textColor =  textField == websiteTextField || textField == emailTextField ? .appPrimaryColor : .black
        
        textField.minimumFontSize = 12
        textField.clearButtonMode = .whileEditing
        textField.setClearButtonImage(image: UIImage(named: "close2"))
        
        textField.addTarget(self, action: #selector(textFieldDidChangeText), for: .editingChanged)
        textField.delegate = self
    }
    
    private func setViewShadow(_ view: UIView) {
        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.appHintColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 12.0
        view.layer.masksToBounds = false
    }
    
    private func setViewsShadow() {
        guard firstAppear else { return }
        firstAppear = false
        setViewShadow(businessView)
        setViewShadow(buttonsView)
        setViewShadow(taxView)
    }
    
    func showTaxForm(onTotal: EmptyBlock? = nil, onDeducted: EmptyBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = nil
        
        form.dopButton1Title = TaxModel.deducted.title
        form.dopButton1Completion = onDeducted
        form.dopButton2Title = TaxModel.onTotal.title
        form.dopButton2Completion = onTotal
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
    
    func setupToolbar() {
        guard let tabbar = self.tabBarController as? BaseTabBarController else { return }
        
        toolbar.alpha = 0.0
        toolbar.tintColor = .appPrimaryColor
        toolbar.overrideUserInterfaceStyle = .light
        toolbar.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 44)
        tabbar.view.addSubview(toolbar)
        
        let attributes1: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.appPrimaryColor,
                                                          .font: UIFont.appSubtitleFont]
        
        let attributes2: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.appPrimaryColor,
                                                          .font: UIFont.appBodyFont]
        
        toolbar.items = []
        
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(toolbarCancelAction))
        cancelBarButton.tintColor = .appPrimaryColor
        cancelBarButton.setTitleTextAttributes(attributes1, for: .normal)
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolbarDoneAction))
        doneBarButton.tintColor = .appPrimaryColor
        doneBarButton.setTitleTextAttributes(attributes2, for: .normal)
        
        toolbar.items?.append(cancelBarButton)
        toolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        toolbar.items?.append(doneBarButton)
        
        toolbarLabel.text = "setting.screen.select.currency.label.text".localized()
        toolbarLabel.textColor = .appCaptionColor
        toolbarLabel.font = .appBody3SemiboldFont
        toolbarLabel.textAlignment = .center
        toolbarLabel.frame = CGRect(x: 2, y: 2, width: UIScreen.main.bounds.width - 4, height: 40)
        toolbar.addSubview(toolbarLabel)
    }
    
    func setupPicker() {
        guard let tabbar = self.tabBarController as? BaseTabBarController else { return }
        
        currencyNames = presenter?.currencyDataSource() ?? [:]
        pickerDataSource = currencyNames.keys.compactMap({ $0 }).sorted()
        
        picker.alpha = 0.0
        picker.overrideUserInterfaceStyle = .light
        picker.backgroundColor = .appBackgroundColor
        picker.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + 44, width: UIScreen.main.bounds.width, height: 250)
        tabbar.view.addSubview(picker)
        
        picker.delegate = self
        picker.dataSource = self
    }
    
    func hidePicker(completion: EmptyBlock? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.blockView.alpha = 0.0
            self.picker.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + 44, width: UIScreen.main.bounds.width, height: 250)
            self.toolbar.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 44)
            self.view.layoutSubviews()
        }, completion: { _ in
            self.picker.alpha = 0.0
            self.toolbar.alpha = 0.0
            completion?()
        })
    }
    
    func showPicker(completion: EmptyBlock? = nil) {
        picker.alpha = 1.0
        toolbar.alpha = 1.0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blockView.alpha = 1.0
            self.picker.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 250, width: UIScreen.main.bounds.width, height: 250)
            self.toolbar.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 294, width: UIScreen.main.bounds.width, height: 44)
            self.view.layoutSubviews()
        }, completion: { _ in
            completion?()
        })
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return presenter?.isPremium() == true ? 0 : 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 84
        case 1:
            return presenter?.isPremium() == true ? 356 : 348
        case 2:
            return 142
        case 3:
            return 194
        case 4:
            return 202
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return premiumCell
        case 1:
            return businessCell
        case 2:
            return currencyCell
        case 3:
            return taxCell
        case 4:
            return buttonsCell
        default:
            return UITableViewCell()
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChangeText(_ textField: UITextField) {
        if textField == nameTextField, let name = textField.text, !name.isEmpty {
            presenter?.setBussinessName(name)
        } else if textField == numberTextField {
            presenter?.setBussinessNumber(textField.text)
        } else if textField == emailTextField {
            presenter?.setBussinessEmail(textField.text)
        } else if textField == phoneTextField {
            presenter?.setBussinessPhone(textField.text)
        } else if textField == websiteTextField {
            presenter?.setBussinessWebsite(textField.text)
        } else if textField == addressTextField {
            presenter?.setBussinessAddress(textField.text)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        
        if textField == emailTextField { textField.textColor = .black }
        if textField == websiteTextField { textField.textColor = .black }
        
        if textField == taxTextField {
            guard var text = textField.text else { return }
            text = text.replacingOccurrences(of: "%", with: "")
            text = text.replacingOccurrences(of: ",", with: ".")
            textField.text = text
            
            guard let value = Double(text) else { return }
            textField.text = presenter?.stringAmount(value)
            
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField { textField.textColor = .appPrimaryColor }
        if textField == websiteTextField { textField.textColor = .appPrimaryColor }
        
        if textField == taxTextField {
            guard let presenter = presenter else { return }
            guard var text = textField.text else { return }
            if text.isEmpty { text = "0" }
            
            let taxValue = Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            textField.text = presenter.stringPercent(taxValue)
            
            guard taxValue > 0 else { return }
            presenter.setTaxValue(taxValue)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            numberTextField.becomeFirstResponder()
        } else if textField == numberTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            phoneTextField.becomeFirstResponder()
        } else if textField == phoneTextField {
            websiteTextField.becomeFirstResponder()
        } else if textField == websiteTextField {
            addressTextField.becomeFirstResponder()
        } else if textField == addressTextField {
            taxTextField.becomeFirstResponder()
        } else if textField == taxTextField {
            hideKeyboard()
        }
        
        return true
    }
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let country = pickerDataSource[row]
        guard let symbol = currencyNames[country] else { return country }
        return country + " (" + symbol + ")"
    }
}
