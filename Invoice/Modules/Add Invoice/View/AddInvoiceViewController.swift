//
//  AddInvoiceViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit
import PDFKit

protocol AddInvoiceViewInput: BaseViewInput {
    func setupInitialState(clients: [ClientModel], items: [ItemModel])
}

class AddInvoiceViewController: BaseViewController {

    var presenter: AddInvoiceViewOutput?
    var mainPresenter: MainViewOutput?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: PrimaryButton!
    @IBOutlet weak var previewButton: SecondaryButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var infoCell: UITableViewCell!
    @IBOutlet var infoBackView: UIView!
    @IBOutlet weak var invoiceNumberLabel: UILabel!
    @IBOutlet weak var issueDateLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var invoiceNumberValueLabel: UILabel!
    @IBOutlet weak var issueDateValue: UITextField!
    @IBOutlet weak var dueDateValue: UITextField!
    
    @IBOutlet var clientCell: UITableViewCell!
    @IBOutlet var clientBackView: UIView!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var deleteClientButton: UIButton!
    @IBOutlet weak var addClientButton: UIButton!
    
    @IBOutlet var addItemCell: UITableViewCell!
    @IBOutlet var addItemBackView: UIView!
    @IBOutlet weak var addItemLabel: UILabel!
    @IBOutlet weak var addItemButton: UIButton!
    
    @IBOutlet var subtotalCell: UITableViewCell!
    @IBOutlet var subtotalBackView: UIView!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var subtotalAmountLabel: UILabel!
    
    @IBOutlet var balanceCell: UITableViewCell!
    @IBOutlet var balanceBackView: UIView!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var discountAmountLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var taxAmountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceAmountLabel: UILabel!
    @IBOutlet weak var paidDateLabel: UILabel!
    @IBOutlet weak var balanceAmountLabelCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet var notesView: UIView!
    @IBOutlet var notesTextView: UITextView!
    
    var firstAppear = true
    var hasChanges = false
    var isDublicate = false
    
    var draft: DraftInvoiceModel!
    
    var clients: [ClientModel] = []
    var items: [ItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupItemsCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    @IBAction func backButtonAction() {
        
        let onDiscard: EmptyBlock = { self.navigationController?.popViewController(animated: true) }
        let onSave: EmptyBlock = {
            guard self.draft.client != nil else {
                self.showErrorMessage("add.invoice.no.client.error.text".localized(), completion: nil)
                return
            }
            
            guard self.draft.draftItems.count > 0 || self.draft.items.count > 0 else {
                self.showErrorMessage("add.invoice.no.items.error.text".localized(), completion: nil)
                return
            }
            
            self.presenter?.saveInvoice(self.draft) { _ in
                onDiscard()
            }
        }
        
        guard hasChanges else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        showConfirmBackForm(onCancel: nil, onSave: onSave, onDiscard: onDiscard)
    }
    
    @IBAction func sendButtonAction() {
        guard let presenter = mainPresenter else { return }
        
        sendButton.viewTouched {
            self.showLoading()
            self.presenter?.saveInvoice(self.draft) { invoice in
                guard let invoice = invoice else {
                    self.hasChanges = false
                    self.hideLoading()
                    return
                }
                
                if let client = self.clients.filter({ $0.clientId == invoice.clientId }).first {
                    self.showSelectTemplateForm(onCancel: nil) { template in
                        guard presenter.canShare(template) else {
                            self.openPaywall()
                            return
                        }
                        
                        self.exportInvoiceToPDF(with: template, model: invoice, client: client, presenter: presenter) { data, url in
                            self.hasChanges = false
                            
                            if let url = url, let data = data {
                                let filename = "Invoice " + invoice.invoiceString + ".pdf"
                                let shareText = data.shareText(invoice: invoice)
                                
                                self.presenter?.setupFirstInvoice(template)
                                self.shareDocument(data: data, filename: filename, shareText: shareText, url: url)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func previewButtonAction() {
        guard let presenter = mainPresenter else { return }
        
        previewButton.viewTouched {
            self.showLoading()
            self.presenter?.saveInvoice(self.draft) { invoice in
                guard let invoice = invoice else {
                    self.hasChanges = false
                    self.hideLoading()
                    return
                }
                
                if let client = self.clients.filter({ $0.clientId == invoice.clientId }).first {
                    self.showSelectTemplateForm(onCancel: nil) { template in
                        self.exportInvoiceToPDF(with: template, model: invoice, client: client, presenter: presenter) { data, url in
                            self.hasChanges = false
                            
                            if let url = url, let data = data {
                                let controller = PreviewConfigurator.instantiateModule(invoice: invoice, data: data, url: url)
                                controller.template = template
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func addClientButtonAction() {
        addClientButton.viewTouched {
            if self.clients.count > 0 {
                let controller = ClientsListConfigurator.instantiateModule()
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = AddClientConfigurator.instantiateModule()
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction func deleteClientButtonAction() {
        guard !draft.paid else { return }
        
        deleteClientButton.viewTouched {
            self.draft.client = nil
            self.hasChanges = true
            self.setupClientCell()
            
            self.sendButton.isEnabled = self.checkButtonsEnabledStatus()
            self.previewButton.isEnabled = self.checkButtonsEnabledStatus()
        }
    }
    
    @IBAction func addItemButtonAction() {
        guard !draft.paid else { return }
        
        addItemButton.viewTouched {
            if self.items.count > 0 {
                let controller = ItemsListConfigurator.instantiateModule()
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = AddItemConfigurator.instantiateModule()
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension AddInvoiceViewController: AddInvoiceViewInput {
    func setupInitialState(clients: [ClientModel], items: [ItemModel]) {
        self.clients = clients
        self.items = items
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemInvoiceCell.self)
        tableView.register(DraftItemInvoiceCell.self)
        
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = .appTitleFont
        
        sendButton.setTitle("add.invoice.screen.send.button.title".localized(), for: .normal)
        previewButton.setTitle("add.invoice.screen.preview.button.title".localized(), for: .normal)
        
        if draft == nil {
            backButton.setTitle("add.invoice.screen.back.button.title".localized(), for: .normal)
            
            guard let presenter = presenter else { return }
            let num = presenter.invoiceNumber()
        
            draft = DraftInvoiceModel()
            draft.currentIssueDate = presenter.stringDate(Date())
            draft.currentDueDate = presenter.stringDate(presenter.dueDate(fromIssueDate: Date()))
            draft.currentNumber = num.0
            draft.currentNumberString = num.1
        } else if isDublicate {
            backButton.setTitle("add.invoice.screen.back.button.title.3".localized(), for: .normal)
        } else {
            backButton.setTitle("add.invoice.screen.back.button.title.2".localized(), for: .normal)
        }
        
        sendButton.isEnabled = checkButtonsEnabledStatus()
        previewButton.isEnabled = checkButtonsEnabledStatus()
    }
    
    func reloadData() {
        self.setupInfoCell()
        self.setupClientCell()
        self.setupItemsCell()
        self.setupBalanceCell()
        
        self.tableView.reloadData()
        self.sendButton.isEnabled = self.checkButtonsEnabledStatus()
        self.previewButton.isEnabled = self.checkButtonsEnabledStatus()
    }
    
    func checkButtonsEnabledStatus() -> Bool {
        guard draft.client != nil else { return false }
        guard draft.draftItems.count > 0 || draft.items.count > 0 else { return false }
        return true
    }
    
    func setupInfoCell() {
        infoBackView.clipsToBounds = true
        infoBackView.layer.cornerRadius = 12
        infoBackView.backgroundColor = .white
        
        invoiceNumberLabel.text = "add.invoice.number.label.text".localized()
        invoiceNumberLabel.textColor = .black
        invoiceNumberLabel.font = .appSubtitleFont
        
        issueDateLabel.text = "add.invoice.issue.date.label.text".localized()
        issueDateLabel.textColor = .black
        issueDateLabel.font = .appSubtitleFont
        
        dueDateLabel.text = "add.invoice.due.date.label.text".localized()
        dueDateLabel.textColor = .black
        dueDateLabel.font = .appSubtitleFont
        
        invoiceNumberValueLabel.text = draft.currentNumberString
        invoiceNumberValueLabel.textColor = .black
        invoiceNumberValueLabel.font = .appSubtitleFont
        
        issueDateValue.backgroundColor = .clear
        issueDateValue.text = draft.currentIssueDate
        issueDateValue.textColor = .black
        issueDateValue.tintColor = .clear
        issueDateValue.font = .appSubtitleFont
        issueDateValue.placeholder = "add.invoice.issue.date.label.text".localized()
        setIssueDatePicker()
        
        dueDateValue.backgroundColor = .clear
        dueDateValue.text = draft.currentDueDate
        dueDateValue.textColor = .black
        dueDateValue.tintColor = .clear
        dueDateValue.font = .appSubtitleFont
        dueDateValue.placeholder = "add.invoice.due.date.label.text".localized()
        setDueDatePicker()
    }
    
    func setupClientCell() {
        clientBackView.clipsToBounds = true
        clientBackView.layer.cornerRadius = 12
        clientBackView.backgroundColor = .white
        
        clientLabel.text = "add.invoice.client.label.text".localized()
        clientLabel.textColor = .black
        clientLabel.font = .appSubtitleFont
        
        clientNameLabel.alpha = draft.client == nil ? 0.0 : 1.0
        clientNameLabel.text = draft.client?.name
        clientNameLabel.textColor = .black
        clientNameLabel.font = .appSubtitleFont
        
        deleteClientButton.alpha = draft.client == nil ? 0.0 : 1.0
        deleteClientButton.isEnabled = !draft.paid
        
        addClientButton.alpha = draft.client == nil ? 1.0 : 0.0
        addClientButton.isEnabled = !draft.paid
        addClientButton.setTitle("add.invoice.add.client.button.title".localized(), for: .normal)
        addClientButton.setTitleColor(!draft.paid ? .appPrimaryColor : .appHintColor, for: .normal)
        addClientButton.titleLabel?.font = .appSubtitleFont
    }
    
    func setupItemsCell() {
        addItemBackView.roundCorners(corners: .allCorners, radius: 0)
        subtotalBackView.roundCorners(corners: .allCorners, radius: 0)
        
        addItemBackView.clipsToBounds = true
        addItemBackView.backgroundColor = .white
        addItemBackView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        
        addItemLabel.text = "add.invoice.items.label.text".localized()
        addItemLabel.textColor = .black
        addItemLabel.font = .appBodyFont
        
        addItemButton.isEnabled = !draft.paid
        addItemButton.setTitle("add.invoice.add.item.button.title".localized(), for: .normal)
        addItemButton.setTitleColor(!draft.paid ? .appPrimaryColor : .appHintColor, for: .normal)
        addItemButton.titleLabel?.font = .appSubtitleFont
        
        subtotalBackView.clipsToBounds = true
        subtotalBackView.backgroundColor = .white
        subtotalBackView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
        
        subtotalLabel.text = "add.invoice.subtotal.label.text".localized()
        subtotalLabel.textColor = .black
        subtotalLabel.font = .appBodyFont
        
        subtotalAmountLabel.text = presenter?.stringAmount(draft.subtotal)
        subtotalAmountLabel.textColor = .black
        subtotalAmountLabel.font = .appBodyFont
    }
    
    func setupBalanceCell() {
        guard let presenter = presenter else { return }
        balanceBackView.clipsToBounds = true
        balanceBackView.layer.cornerRadius = 12
        balanceBackView.backgroundColor = .white
        
        discountLabel.text = "add.invoice.discount.label.text".localized()
        discountLabel.textColor = .black
        discountLabel.font = .appSubtitleFont
        
        taxLabel.text = "add.invoice.tax.label.text".localized()
        taxLabel.textColor = .black
        taxLabel.font = .appSubtitleFont
        
        totalLabel.text = "add.invoice.total.label.text".localized()
        totalLabel.textColor = .black
        totalLabel.font = .appSubtitleFont
        
        balanceLabel.text = "add.invoice.balance.label.text".localized()
        balanceLabel.textColor = .black
        balanceLabel.font = .appBodyFont
        
        discountAmountLabel.text = (draft.discount > 0 ? "-" : "") + presenter.stringAmount(draft.discount)
        discountAmountLabel.textColor = .appHintColor
        discountAmountLabel.font = .appSubtitleFont
        
        taxAmountLabel.text = presenter.stringAmount(draft.tax)
        taxAmountLabel.textColor = .appHintColor
        taxAmountLabel.font = .appSubtitleFont
        
        totalAmountLabel.text = presenter.stringAmount(draft.total)
        totalAmountLabel.textColor = .black
        totalAmountLabel.font = .appSubtitleFont
        
        balanceAmountLabel.text = presenter.stringAmount(draft.balance)
        balanceAmountLabel.textColor = .black
        balanceAmountLabel.font = .appBodyFont
        balanceAmountLabelCenterConstraint.constant = 0
        
        paidDateLabel.text = ""
        paidDateLabel.alpha = 0.0
        paidDateLabel.textColor = .appPrimaryColor
        paidDateLabel.font = .appButtonFont3
        
        if let paidDate = draft.paidDate {
            paidDateLabel.text = "add.invoice.paid.date.label.text".localized() + " " + presenter.stringDate(paidDate)
            paidDateLabel.alpha = 1.0
            balanceAmountLabelCenterConstraint.constant = -8.0
        }
        
        notesView.clipsToBounds = true
        notesView.layer.cornerRadius = 12
        notesView.backgroundColor = .white
        
        notesTextView.text = draft.notes ?? draft.notesPlaceholder
        notesTextView.textColor = notesTextView.text == draft.notesPlaceholder ? .appHintColor : .black
        notesTextView.font = .appBody2Font
        notesTextView.delegate = self
    }
}

extension AddInvoiceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return draft.draftItems.count
        case 2:
            return draft.items.count
        case 3:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 172
            case 1:
                return 68
            case 2:
                return 60
            default:
                return 0
            }
        case 1:
            return 52
        case 2:
            return 52
        case 3:
            switch indexPath.row {
            case 0:
                return 60
            case 1:
                return 340
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return infoCell
            case 1:
                return clientCell
            case 2:
                return addItemCell
            default:
                return UITableViewCell()
            }
        case 1:
            let cell: DraftItemInvoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            let index = indexPath.row
            let model = draft.draftItems[index]
            cell.configure(model: model, index: index)
            return cell
        case 2:
            let cell: ItemInvoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.delegate = self
            let index = indexPath.row
            let model = draft.items[index]
            cell.configure(model: model, index: index)
            return cell
        case 3:
            switch indexPath.row {
            case 0:
                return subtotalCell
            case 1:
                return balanceCell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
}

extension AddInvoiceViewController {
    
    func setIssueDatePicker() {
        guard let presenter = presenter else { return }
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.tintColor = .appPrimaryColor
        datePicker.addTarget(self, action: #selector(handleIssueDatePicker(sender:)), for: .valueChanged)
        
        if let text = issueDateValue.text, let date = presenter.dateString(text) {
            datePicker.date = date
        }
        
        issueDateValue.inputView = datePicker
    
        guard #available(iOS 14.0, *) else { return }
        datePicker.preferredDatePickerStyle = .inline
    }
        
    @objc func handleIssueDatePicker(sender: UIDatePicker) {
        guard let presenter = presenter else { return }
        
        draft.currentIssueDate = presenter.stringDate(sender.date)
        issueDateValue.text = draft.currentIssueDate
        hasChanges = true
    }
    
    func setDueDatePicker() {
        guard let presenter = presenter else { return }
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.tintColor = .appPrimaryColor
        datePicker.addTarget(self, action: #selector(handleDueDatePicker(sender:)), for: .valueChanged)
        
        if let text = dueDateValue.text, let date = presenter.dateString(text) {
            datePicker.date = date
        }
        
        dueDateValue.inputView = datePicker
    
        guard #available(iOS 14.0, *) else { return }
        datePicker.preferredDatePickerStyle = .inline
    }
        
    @objc func handleDueDatePicker(sender: UIDatePicker) {
        guard let presenter = presenter else { return }
        
        var dueDate = sender.date
        if let issueDate = presenter.dateString(draft.currentIssueDate), dueDate < issueDate {
            dueDate = issueDate
            sender.date = issueDate
        }
        
        draft.currentDueDate = presenter.stringDate(dueDate)
        dueDateValue.text = draft.currentDueDate
        hasChanges = true
    }
}

extension AddInvoiceViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == draft.notesPlaceholder { textView.text = "" }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty || text == draft.notesPlaceholder {
            draft.notes = nil
            textView.text = draft.notesPlaceholder
            textView.textColor = .appHintColor
            return
        }
        
        draft.notes = text
        textView.textColor = .black
    }
    
    func textViewDidChange(_ textView: UITextView) {
        hasChanges = true
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty || text == draft.notesPlaceholder {
            draft.notes = nil
            return
        }
        
        draft.notes = text
        textView.textColor = .black
    }
}
