//
//  AddClientViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit
import ContactsUI

protocol AddClientViewInput: BaseViewInput {
    func setupInitialState()
}

class AddClientViewController: BaseViewController {

    var presenter: AddClientViewOutput?
    var selectedContact: CNContact?
    
    var delegate: BaseViewController?
    var client: ClientModel?
    
    var firstAppear = true
    
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var importButton: SecondaryButton!
    @IBOutlet weak var saveButton: PrimaryButton!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var importButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setViewShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        saveContact()
    }
    
    @IBAction func backButtonAction() {
        hideKeyboard()
        backButton.viewTouched {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func importButtonAction() {
        hideKeyboard()
        importButton.viewTouched {
            self.checkContactsAccess()
        }
    }
    
    @IBAction func saveButtonAction() {
        guard let presenter = presenter else { return }
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        let email = emailTextField.text
        let phone = phoneTextField.text
        let address = addressTextField.text
        
        hideKeyboard()
        saveButton.viewTouched {
            if !presenter.isPremium() && presenter.clientsCount() >= Constants.shared.freeModeMaxClients {
                self.openPaywall()
                return
            }
            
            if let client = self.client {
                self.showLoading()
                ClientModel.updateClient(client, name: name, email: email, phone: phone, address: address) { _ in
                    self.hideLoading()
                    self.navigationController?.popViewController(animated: true)
                }
                
                return
            }
            
            self.showLoading()
            ClientModel.addClient(name, email: email, phone: phone, address: address) { model in
                if let model = model, let controller = self.delegate as? AddInvoiceViewController {
                    controller.draft.client = model
                    controller.clients.append(model)
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
}

extension AddClientViewController: AddClientViewInput {
    func setupInitialState() {
        backButton.setTitle("add.client.screen.header.label.text".localized(), for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = .appTitleFont
        
        importButton.setTitle("add.client.screen.choose.button.title".localized(), for: .normal)
        saveButton.setTitle("add.client.screen.save.button.title".localized(), for: .normal)
        saveButton.isEnabled = false
        
        nameLabel.text = "add.client.screen.name.label.text".localized()
        nameLabel.textColor = .black
        nameLabel.font = .appSubtitleFont
        
        emailLabel.text = "add.client.screen.email.label.text".localized()
        emailLabel.textColor = .black
        emailLabel.font = .appSubtitleFont
        
        phoneLabel.text = "add.client.screen.phone.label.text".localized()
        phoneLabel.textColor = .black
        phoneLabel.font = .appSubtitleFont
        
        addressLabel.text = "add.client.screen.address.label.text".localized()
        addressLabel.textColor = .black
        addressLabel.font = .appSubtitleFont
        
        nameTextField.placeholder = "add.client.screen.name.label.text".localized()
        emailTextField.placeholder = "add.client.screen.email.label.text".localized()
        phoneTextField.placeholder = "add.client.screen.phone.label.text".localized()
        addressTextField.placeholder = "add.client.screen.address.label.text".localized()
        
        setupTextField(nameTextField)
        setupTextField(emailTextField)
        setupTextField(phoneTextField)
        setupTextField(addressTextField)
        
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 12
        backView.backgroundColor = .white
        
        if let client = self.client {
            importButton.alpha = 0.0
            importButtonHeightConstraint.constant = 0.0
            backViewTopConstraint.constant = 0.0
            
            backButton.setTitle("add.client.screen.edit.header.label.text".localized(), for: .normal)
            saveButton.isEnabled = true
            
            nameTextField.text = client.name
            emailTextField.text = client.email
            phoneTextField.text = client.phone
            addressTextField.text = client.address
        }
    }
    
    func setupTextField(_ textField: UITextField) {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.appHintColor, .font : UIFont.appSubtitleFont]
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: attributes)
        
        textField.backgroundColor = .clear
        textField.text = nil
        textField.tintColor = .black
        textField.font = .appBody2Font
        textField.textColor = textField == emailTextField ? .appPrimaryColor : .black
        
        textField.minimumFontSize = 12
        textField.clearButtonMode = .whileEditing
        textField.setClearButtonImage(image: UIImage(named: "close2"))
        
        textField.delegate = self
    }
    
    private func setViewShadow() {
        guard firstAppear else { return }
        firstAppear = false
        
        backView.clipsToBounds = false
        backView.layer.shadowColor = UIColor.appHintColor.cgColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backView.layer.shadowOpacity = 0.5
        backView.layer.shadowRadius = 12.0
        backView.layer.masksToBounds = false
    }
    
    func saveContact() {
        guard let contact = selectedContact else { return }
        
        self.showSaveContactForm(contact, onCancel: {
            self.selectedContact = nil
        }, onSave: {
            self.nameTextField.text = contact.organizationTitle
            self.emailTextField.text = contact.emailAddress
            self.phoneTextField.text = contact.phoneNumber
            self.addressTextField.text = contact.fullAddress
            
            self.saveButton.isEnabled = !contact.organizationTitle.isEmpty
            self.selectedContact = nil
        })
    }
    
    func showSaveContactForm(_ contact: CNContact, onCancel: EmptyBlock? = nil, onSave: EmptyBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let contactName = contact.organizationTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        var alertMessage = "add.client.screen.save.contact.client.message.text".localized()
        alertMessage = alertMessage.replacingOccurrences(of: "$$CONTACT_TITLE$$", with: contactName)
        
        let form = CustomAlertController()
        form.direction = .up
        form.alertMessage = alertMessage
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = onCancel
        
        form.dopButton1Title = "add.client.screen.import.contact.button.title".localized()
        form.dopButton1Completion = onSave
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
}

extension AddClientViewController: UITextFieldDelegate {
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        
        if textField == emailTextField { textField.textColor = .black }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField { textField.textColor = .appPrimaryColor }
        if textField == nameTextField, let text = textField.text { saveButton.isEnabled = !text.isEmpty }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            if let text = textField.text { saveButton.isEnabled = !text.isEmpty }
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            phoneTextField.becomeFirstResponder()
        } else if textField == phoneTextField {
            addressTextField.becomeFirstResponder()
        } else if textField == addressTextField {
            hideKeyboard()
        }
        
        return true
    }
}

extension AddClientViewController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let contactViewController = CNContactViewController(for: contact)
        contactViewController.overrideUserInterfaceStyle = .light
        contactViewController.hidesBottomBarWhenPushed = true
        contactViewController.allowsEditing = false
        contactViewController.allowsActions = false
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(contactViewController, animated: true)
        
        self.selectedContact = contact
    }
    
    private func accessGrantedForContacts() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.overrideUserInterfaceStyle = .light
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    private func checkContactsAccess() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            self.accessGrantedForContacts()
        case .notDetermined:
            self.requestContactsAccess()
        case .denied, .restricted:
            self.showErrorMessage("add.client.screen.no.permission.contacts.message.text".localized(), completion: nil)
        @unknown default:
            fatalError("add.client.screen.no.permission.contacts.message.text".localized())
        }
    }
       
    private func requestContactsAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                self.showErrorMessage(error.localizedDescription, completion: nil)
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    self.accessGrantedForContacts()
                    return
                }
            }
        }
    }
}
