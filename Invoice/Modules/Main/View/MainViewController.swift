//
//  MainViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol MainViewInput: BaseViewInput {
    func setupInitialState()
}

class MainViewController: BaseViewController {

    var presenter: MainViewOutput?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var addButton: PrimaryButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var items: [ItemModel] = []
    var clients: [ClientModel] = []
    var invoices: [InvoiceModel] = []
    var dataSource: [InvoiceModel] = []
    
    var selectedItem = 0
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //setTableViewShadow()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    @IBAction func clearButtonAction() {
        clearButton.viewTouched {
            self.segmentedControlValueChanged(sender: self.segmentedControl)
        }
    }
    
    @IBAction func searchButtonAction() {
        showSearchBar { searchText in
            Constants.shared.invoiceSearchText = searchText
            let invoices = self.invoices.filter({ $0.checkSearch(searchText, clients: self.clients) })
            
            guard invoices.count > 0 else {
                self.showAttentionMessage("main.screen.search.nothing.message.text".localized())
                return
            }
            
            self.dataSource = invoices
            self.tableView.reloadData()
            self.tableView.scrollToTop(animated: true)
            self.clearButton.alpha = 1.0
        }
    }
    
    @IBAction func addButtonAction() {
        addButton.viewTouched {
            let controller = AddInvoiceConfigurator.instantiateModule(clients: self.clients, items: self.items)
            controller.mainPresenter = self.presenter
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        selectedItem = sender.selectedSegmentIndex
        clearButton.alpha = 0.0
        
        switch selectedItem {
        case 0:
            dataSource = invoices.sorted(by: { $0.invoiceId > $1.invoiceId })
            tableView.reloadData()
        case 1:
            dataSource = invoices.filter({ $0.paidDate == nil }).sorted(by: { $0.invoiceId > $1.invoiceId })
            tableView.reloadData()
        case 2:
            dataSource = invoices.filter({ $0.paidDate != nil }).sorted(by: { $0.invoiceId > $1.invoiceId })
            tableView.reloadData()
        default:
            break
        }
    }
    
    func openInvoice(_ model: InvoiceModel) {
        let controller = AddInvoiceConfigurator.instantiateModule(clients: clients, items: items)
        controller.mainPresenter = self.presenter
        controller.draft = DraftInvoiceModel.initForEdit(model: model, delegate: self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func dublicateInvoice(_ model: InvoiceModel) {
        let controller = AddInvoiceConfigurator.instantiateModule(clients: clients, items: items)
        controller.isDublicate = true
        controller.mainPresenter = self.presenter
        controller.draft = DraftInvoiceModel.initForDublicate(model: model, delegate: self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openMenu(for model: InvoiceModel) {
        guard let presenter = presenter else { return }
        
        let title = presenter.invoiceHeaderForMenu(model, clients: clients)
        
        showEditForm(title: title, invoice: model, onCancel: nil, onDelete: {
            self.showConfirmDeleteForm(name: model.invoiceString) {
                self.dataSource = []
                self.showLoading()
                InvoiceModel.deleteInvoice(model) {
                    self.reloadData()
                }
            }
        }, onDublicate: {
            self.dublicateInvoice(model)
        }, onSend: {
            guard let client = self.clients.filter({ $0.clientId == model.clientId }).first else { return }
            
            self.showSelectTemplateForm(onCancel: nil) { template in
                self.exportInvoiceToPDF(with: template, model: model, client: client, presenter: presenter) { data, url in
                    if let url = url, let data = data {
                        let controller = PreviewConfigurator.instantiateModule(invoice: model, data: data, url: url)
                        controller.template = template
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
            
            
        }, onPaid: {
            self.showConfirmPaidForm(name: model.invoiceString) {
                self.showLoading()
                InvoiceModel.paidInvoice(model) {
                    self.reloadData()
                }
            }
        }, onUnpaid: {
            self.showConfirmUnpaidForm(name: model.invoiceString) {
                self.showLoading()
                InvoiceModel.unpaidInvoice(model) {
                    self.reloadData()
                }
            }
        })
    }
}

extension MainViewController: MainViewInput {
    func setupInitialState() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InvoiceCell.self)
        
        titleLabel.text = "main.screen.tabbar1.title".localized()
        titleLabel.textColor = .black
        titleLabel.font = .appTitleFont
        
        clearButton.setTitle("main.screen.clear.search.button.title".localized(), for: .normal)
        clearButton.setTitleColor(.appPrimaryColor, for: .normal)
        clearButton.titleLabel?.font = .appButtonFont2
        clearButton.alpha = 0.0
        
        addButton.setTitle("main.screen.add.button.title".localized(), for: .normal)
        setupSegmentedControl()
    }
    
    func reloadData() {
        showLoading()
        presenter?.loadInvoices { invoices in
            self.presenter?.loadClients { clients in
                self.presenter?.loadItems { items in
                    self.items = items
                    self.clients = clients
                    self.invoices = invoices.sorted(by: { $0.invoiceId > $1.invoiceId })
                    
                    self.segmentedControlValueChanged(sender: self.segmentedControl)
                    self.hideLoading()
                }
            }
        }
    }
    
    private func setTableViewShadow() {
        guard firstAppear else { return }
        firstAppear = false
        
        tableView.clipsToBounds = true
        tableView.layer.shadowColor = UIColor.appHintColor.cgColor
        tableView.layer.shadowOffset = CGSize(width: 0, height: 0)
        tableView.layer.shadowOpacity = 0.5
        tableView.layer.shadowRadius = 12.0
        tableView.layer.masksToBounds = true
    }
    
    func setupSegmentedControl() {
        let normalAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appHintColor]
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        
        let selectedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        segmentedControl.setTitle("main.screen.segmented.control.item1.title".localized(), forSegmentAt: 0)
        segmentedControl.setTitle("main.screen.segmented.control.item2.title".localized(), forSegmentAt: 1)
        segmentedControl.setTitle("main.screen.segmented.control.item3.title".localized(), forSegmentAt: 2)
        
        segmentedControl.clipsToBounds = true
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = .white
        segmentedControl.selectedSegmentTintColor = .appHintColor
        segmentedControl.layer.borderColor = UIColor.appHintColor.cgColor
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.layer.cornerRadius = 12.0
        
        segmentedControl.selectedSegmentIndex = selectedItem
    }
    
    func showConfirmPaidForm(name: String, completion: EmptyBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.alertMessage = "main.screen.segmented.control.item3.title".localized() + " " + name + "?"
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = nil
        
        form.dopButton1Title = "main.screen.segmented.control.item3.title".localized()
        form.dopButton1Completion = completion
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
    
    func showConfirmUnpaidForm(name: String, completion: EmptyBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.alertMessage = "main.screen.edit.invoice.button5.title".localized() + " " + name + "?"
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = nil
        
        form.dopButton1Title = "main.screen.edit.invoice.button5.title".localized()
        form.dopButton1Completion = completion
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
    
    func showConfirmDeleteForm(name: String, completion: EmptyBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.alertMessage = "common.delete.button.alert".localized() + " " + name + "?"
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = nil
        
        form.dopButton1Title = "common.delete.button.alert".localized()
        form.dopButton1Completion = completion
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
    
    func showSearchBar(completion: SearchValueBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomSearchController()
        form.direction = .down
        form.searchBarText = Constants.shared.invoiceSearchText
        form.searchBarPlaceholder = "main.screen.search.button.title".localized()
        
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = nil
        
        form.dopButtonTitle = "main.screen.search.button.title".localized()
        form.dopButtonCompletion = completion
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InvoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self
        
        let index = indexPath.row
        let model = dataSource[index]
        let client = clients.filter({ $0.clientId == model.clientId }).first
        cell.configure(model: model, client: client, index: index)
        
        return cell
    }
}

extension MainViewController {
    
    func searchInvoices() {
        
    }
}
