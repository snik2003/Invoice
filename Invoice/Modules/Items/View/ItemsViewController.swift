//
//  ItemsViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol ItemsViewInput: BaseViewInput {
    func setupInitialState()
}

class ItemsViewController: BaseViewController {

    var presenter: ItemsViewOutput?
    
    var items: [ItemModel] = []
    var dataSource: [ItemModel] = []
    
    var firstAppear = true
    
    @IBOutlet weak var titleLabel: UILabel!
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
    
    @IBAction func clearButtonAction() {
        clearButton.viewTouched {
            self.dataSource = self.items.sorted(by: { $0.date > $1.date })
            self.tableView.reloadData()
            self.clearButton.alpha = 0.0
        }
    }
    
    @IBAction func searchButtonAction() {
        showSearchBar { searchText in
            Constants.shared.itemSearchText = searchText
            let items = self.items.filter({ $0.checkSearch(searchText) })
            
            guard items.count > 0 else {
                self.showAttentionMessage("main.screen.search.nothing.message.text".localized())
                return
            }
            
            self.dataSource = items
            self.tableView.reloadData()
            self.tableView.scrollToTop(animated: true)
            self.clearButton.alpha = 1.0
        }
    }
    
    @IBAction func addButtonAction() {
        addButton.viewTouched {
            let controller = AddItemConfigurator.instantiateModule()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openItem(_ item: ItemModel) {
        let controller = AddItemConfigurator.instantiateModule()
        controller.item = item
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ItemsViewController: ItemsViewInput {
    func setupInitialState() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemModelCell.self)
        
        titleLabel.text = "main.screen.tabbar3.title".localized()
        titleLabel.textColor = .black
        titleLabel.font = .appTitleFont
        
        clearButton.setTitle("main.screen.clear.search.button.title".localized(), for: .normal)
        clearButton.setTitleColor(.appPrimaryColor, for: .normal)
        clearButton.titleLabel?.font = .appButtonFont2
        clearButton.alpha = 0.0
        
        addButton.setTitle("items.screen.add.button.title".localized(), for: .normal)
    }
    
    func reloadData() {
        showLoading()
        presenter?.loadItems { items in
            self.items = items
            self.dataSource = items.sorted(by: { $0.date > $1.date })
            self.tableView.reloadData()
            self.tableView.scrollToTop(animated: true)
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
        form.searchBarText = Constants.shared.itemSearchText
        form.searchBarPlaceholder = "items.screen.search.button.title".localized()
        
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = nil
        
        form.dopButtonTitle = "items.screen.search.button.title".localized()
        form.dopButtonCompletion = completion
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
}

extension ItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell: ItemModelCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self
        let model = dataSource[indexPath.row]
        cell.configure(model: model, index: indexPath.row)
        return cell
    }
}
