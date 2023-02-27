//
//  ReportsViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol ReportsViewInput: BaseViewInput {
    func setupInitialState()
}

class ReportsViewController: BaseViewController {

    var presenter: ReportsViewOutput?
    
    var invoices: [InvoiceModel] = []
    var stat: [(String, Int, Int, String)] = []
    
    var year = Date().year()
    var month = Date().month()
    
    var firstAppear = true
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setViewsShadow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    @IBAction func dateButtonAction() {
        
        var years: [Int] = []
        
        if self.year != Date().yearDifference(byAdding: -4) {
            years.append(Date().yearDifference(byAdding: -4))
        }
        
        if self.year != Date().yearDifference(byAdding: -3) {
            years.append(Date().yearDifference(byAdding: -3))
        }
        
        if self.year != Date().yearDifference(byAdding: -2) {
            years.append(Date().yearDifference(byAdding: -2))
        }
        
        if self.year != Date().yearDifference(byAdding: -1) {
            years.append(Date().yearDifference(byAdding: -1))
        }
        
        if self.year != Date().year() {
            years.append(Date().year())
        }
        
        dateView.viewTouched(duration: 0.05) {
            self.showSelectYearForm(years: years, onCurrent1: {
                self.year = years[0]
                self.yearLabel.text = String(self.year)
                self.reloadData()
            }, onCurrent2: {
                self.year = years[1]
                self.yearLabel.text = String(self.year)
                self.reloadData()
            }, onCurrent3: {
                self.year = years[2]
                self.yearLabel.text = String(self.year)
                self.reloadData()
            }, onCurrent4: {
                self.year = years[3]
                self.yearLabel.text = String(self.year)
                self.reloadData()
            })
        }
    }
}

extension ReportsViewController: ReportsViewInput {
    func setupInitialState() {
        titleLabel.text = "main.screen.tabbar4.title".localized()
        titleLabel.textColor = .black
        titleLabel.font = .appTitleFont
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(ReportCell.self)
        
        dateView.clipsToBounds = true
        dateView.layer.cornerRadius = 12.0
        dateView.backgroundColor = .white
        
        dateLabel.text = "reports.screen.date.label.text".localized()
        dateLabel.textColor = .appHintColor
        dateLabel.font = .appButtonFont2
        
        yearLabel.text = String(year)
        yearLabel.textColor = .appPrimaryColor
        yearLabel.font = .appButtonFont
        
        totalView.clipsToBounds = true
        totalView.layer.cornerRadius = 12.0
        totalView.backgroundColor = .white
        
        totalLabel.text = "reports.screen.total.label.text".localized()
        totalLabel.textColor = .appHintColor
        totalLabel.font = .appButtonFont2
        
        amountLabel.text = presenter?.stringAmount(0.0)
        amountLabel.textColor = .black
        amountLabel.font = .appBodyFont
        
        label1.text = "reports.screen.clients.count.label.text".localized()
        label1.font = .appSubtitleFont
        label1.textColor = .black
        label1.alpha = 0.0
        
        label2.text = "reports.screen.invoices.count.label.text".localized()
        label2.font = .appSubtitleFont
        label2.textColor = .black
        label2.alpha = 0.0
        
        label3.text = "reports.screen.paid.amount.label.text".localized()
        label3.font = .appSubtitleFont
        label3.textColor = .black
        label3.alpha = 0.0
    }
    
    func reloadData() {
        guard let presenter = presenter else { return }
        
        showLoading()
        presenter.loadInvoices { invoices in
            self.invoices = invoices
        
            let totalAmount = presenter.totalAmount(for: invoices, inYear: self.year)
            self.amountLabel.text = presenter.stringAmount(totalAmount)
            
            self.stat = presenter.monthStat(for: self.year, invoices: invoices)
            self.tableView.reloadData()
            self.tableView.scrollToTop(animated: true)
            
            self.label1.alpha = 1.0
            self.label2.alpha = 1.0
            self.label3.alpha = 1.0
            self.hideLoading()
        }
    }
    
    func showSelectYearForm(years: [Int], onCurrent1: EmptyBlock? = nil, onCurrent2: EmptyBlock? = nil,
                            onCurrent3: EmptyBlock? = nil, onCurrent4: EmptyBlock? = nil) {
        
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = nil
        
        form.dopButton1Title = String(years[0])
        form.dopButton1Completion = onCurrent1
        
        form.dopButton2Title = String(years[1])
        form.dopButton2Completion = onCurrent2
        
        form.dopButton3Title = String(years[2])
        form.dopButton3Completion = onCurrent3
         
        form.dopButton4Title = String(years[3])
        form.dopButton4Completion = onCurrent4
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
    
    private func setViewShadow(_ view: UIView) {
        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.appHintColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 12.0
        view.layer.masksToBounds = false
    }
    
    private func setTableViewShadow() {
        tableView.clipsToBounds = true
        tableView.layer.shadowColor = UIColor.appHintColor.cgColor
        tableView.layer.shadowOffset = CGSize(width: 0, height: 0)
        tableView.layer.shadowOpacity = 0.5
        tableView.layer.shadowRadius = 0.0
        tableView.layer.masksToBounds = false
    }
    
    private func setViewsShadow() {
        guard firstAppear else { return }
        firstAppear = false
        
        setViewShadow(dateView)
        setViewShadow(totalView)
        setViewShadow(headerView)
        //setTableViewShadow()
    }
}

extension ReportsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + stat.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let presenter = presenter else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            let stat = presenter.yearStat(for: year, invoices: invoices)
            let cell: ReportCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(title: String(year), clientCount: stat.0, invoicesCount: stat.1, paidAmount: stat.2, year: true)
            return cell
        }
        
        let stat = self.stat[indexPath.row - 1]
        let cell: ReportCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(title: stat.0, clientCount: stat.1, invoicesCount: stat.2, paidAmount: stat.3)
        return cell
    }
}
