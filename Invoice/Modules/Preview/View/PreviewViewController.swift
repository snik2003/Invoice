//
//  PreviewViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 05.12.2022.
//

import UIKit
import PDFKit

protocol PreviewViewInput: BaseViewInput {
    func setupInitialState(invoice: InvoiceModel, data: NSData, url: URL)
}

class PreviewViewController: BaseViewController {

    var presenter: PreviewViewOutput?
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sendButton: PrimaryButton!
    
    var template: Int = 0
    var document: PDFDocument!
    var invoice: InvoiceModel!
    var data: NSData!
    var url: URL!
    
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setPDFViewShadow()
    }
    
    @IBAction func backButtonAction() {
        backButton.viewTouched {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func sendButtonAction() {
        guard presenter?.canShare(template) == true else {
            self.openPaywall()
            return
        }
        
        let filename = "Invoice " + invoice.invoiceString + ".pdf"
        let shareText = data.shareText(invoice: invoice)
        
        sendButton.viewTouched {
            self.presenter?.setupFirstInvoice(self.template)
            self.shareDocument(data: self.data, filename: filename, shareText: shareText, url: self.url)
        }
    }
    
    @IBAction func shareButtonAction() {
        guard presenter?.canShare(template) == true else {
            self.openPaywall()
            return
        }
        
        let filename = "Invoice " + invoice.invoiceString + ".pdf"
        let shareText = data.shareText(invoice: invoice)
        
        shareButton.viewTouched {
            self.presenter?.setupFirstInvoice(self.template)
            self.shareDocument(data: self.data, filename: filename, shareText: shareText, url: self.url)
        }
    }
}

extension PreviewViewController: PreviewViewInput {
    
    func setupInitialState(invoice: InvoiceModel, data: NSData, url: URL) {
        self.invoice = invoice
        self.data = data
        self.url = url
        
        backButton.setTitle("preview.screen.back.button.title".localized(), for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.titleLabel?.font = .appTitleFont
        
        sendButton.setTitle("preview.screen.send.button.title".localized(), for: .normal)
        
        pdfView.clipsToBounds = true
        pdfView.backgroundColor = .white
    }
    
    func loadPDF() {
        if let document = PDFDocument(url: url) {
            self.document = document
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            pdfView.displayDirection = .vertical
            pdfView.document = document
        }
    }
    
    private func setPDFViewShadow() {
        guard firstAppear else { return }
        firstAppear = false
        loadPDF()
        
        pdfView.clipsToBounds = false
        pdfView.layer.shadowColor = UIColor.appHintColor.cgColor
        pdfView.layer.shadowOffset = CGSize(width: 0, height: 0)
        pdfView.layer.shadowOpacity = 0.5
        pdfView.layer.shadowRadius = 0.0
        pdfView.layer.masksToBounds = false
    }
}

extension NSData {
    
    func shareText(invoice: InvoiceModel) -> String {
        return "Invoice \(invoice.invoiceString) • PDF • \(sizeInMegaBytes)"
    }
    
    private var sizeInMegaBytes: String {
        let size = Int64(count)
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = size < 1024 ? [.useBytes] : size < (1024 * 1024) / 10 ? [.useKB] : [.useMB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: size)
    }
}
