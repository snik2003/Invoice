//
//  ClientsListViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit

protocol ClientsListViewInput: BaseViewInput {
    func setupInitialState()
}

class ClientsListViewController: BaseViewController {

    var presenter: ClientsListViewOutput?
    var delegate: BaseViewController?
    
    var clients: [ClientModel] = []
    var dataSource: [ClientModel] = []
    
    var firstAppear = true
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var addButton: PrimaryButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //setTableViewShadow()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    @IBAction func backButtonAction() {
        backButton.viewTouched {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func clearButtonAction() {
        clearButton.viewTouched {
            self.dataSource = self.clients.sorted(by: { $0.name < $1.name })
            self.tableView.reloadData()
            self.tableView.scrollToTop(animated: true)
            self.clearButton.alpha = 0.0
        }
    }
    
    @IBAction func searchButtonAction() {
       showSearchBar { searchText in
            Constants.shared.clientSearchText = searchText
            let clients = self.clients.filter({ $0.checkSearch(searchText) })
            
            guard clients.count > 0 else {
                self.showAttentionMessage("main.screen.search.nothing.message.text".localized())
                return
            }
            
            self.dataSource = clients
            self.tableView.reloadData()
            self.tableView.scrollToTop(animated: true)
            self.clearButton.alpha = 1.0
        }
    }
    
    @IBAction func addButtonAction() {
        addButton.viewTouched {
            let controller = AddClientConfigurator.instantiateModule()
            controller.delegate = self.delegate
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ClientsListViewController: ClientsListViewInput {
    func setupInitialState() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ClientModelCell.self)
        
        backButton.setTitle("clients.list.screen.header.label.text".localized(), for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = .appTitleFont
        
        clearButton.setTitle("main.screen.clear.search.button.title".localized(), for: .normal)
        clearButton.setTitleColor(.appPrimaryColor, for: .normal)
        clearButton.titleLabel?.font = .appButtonFont2
        clearButton.alpha = 0.0
        
        addButton.setTitle("clients.screen.add.button.title".localized(), for: .normal)
    }
    
    func reloadData() {
        showLoading()
        presenter?.loadClients { clients in
            self.clients = clients
            self.dataSource = clients.sorted(by: { $0.name < $1.name })
            self.tableView.reloadData()
            self.clearButton.alpha = 0.0
            self.hideLoading()
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
        tableView.layer.masksToBounds = false
    }
    
    func showSearchBar(completion: SearchValueBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomSearchController()
        form.direction = .down
        form.searchBarText = Constants.shared.clientSearchText
        form.searchBarPlaceholder = "clients.screen.search.button.title".localized()
        
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = nil
        
        form.dopButtonTitle = "clients.screen.search.button.title".localized()
        form.dopButtonCompletion = completion
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
}

extension ClientsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ClientModelCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self
        let model = dataSource[indexPath.row]
        cell.configure(model: model, index: indexPath.row)
        return cell
    }
}



