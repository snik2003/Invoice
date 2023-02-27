//
//  BaseViewInput.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit
import StoreKit
import ApphudSDK
import SafariServices

protocol BaseViewInput: AnyObject {
    
    func showLoading()
    func hideLoading()
    func openURL(stringURL: String)
    func openContactDeveloperModule()
    func openTermsOfUse()
    func openPrivacyPolicy()
}

extension BaseViewController: BaseViewInput {
    
    func showLoading() {
        LoadingViewController().showLoading(view: self.view)
    }
    
    func hideLoading() {
        LoadingViewController().hideLoading()
    }
    
    func openURL(stringURL: String) {
        if let url = URL(string: stringURL) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let safariController = SFSafariViewController(url: url, configuration: config)
            safariController.preferredControlTintColor = .appBackgroundColor
            safariController.preferredBarTintColor = .appPrimaryColor
            
            present(safariController, animated: true)
        }
    }
    
    func openContactDeveloperModule() {
        openURL(stringURL: Constants.shared.contactDeveloperURL)
    }
    
    func openTermsOfUse() {
        openURL(stringURL: Constants.shared.termsOfUseURL)
    }
    
    func openPrivacyPolicy() {
        openURL(stringURL: Constants.shared.privacyPolicyURL)
    }
    
    func shareDocument(data: NSData, filename: String, shareText: String, url: URL) {
        
        let activityItems: [Any] = [data, TextProvider(filename: filename, shareText: shareText, url: url)]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.overrideUserInterfaceStyle = .light
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func restorePurchases() {
        showLoading()
        Apphud.restorePurchases { subscriptions, purchases, error in
            var appDataService: AppDataServiceProtocol = serviceLocator.getService()
            appDataService.isPremiumMode = Apphud.hasActiveSubscription()
            
            self.hideLoading()
            if let error = error {
                self.showAttentionMessage(error.localizedDescription)
            } else if appDataService.isPremiumMode {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                appDelegate.setupRootViewController()
            } else {
                self.showAttentionMessage("paywall.screen.restore.purchases.no.active.subscription.title".localized())
            }
        }
    }
    
    func openPaywall(isOnboard: Bool = false) {
        
        guard !Constants.shared.isTestMode else {
            Constants.shared.getStoreProducts()
            
            let controller = PaywallConfigurator.instantiateModule()
            controller.isOnboard = isOnboard
            
            if isOnboard {
                guard let navigationController = self.navigationController else { return }
                navigationController.pushViewController(controller, animated: false)
            } else {
                guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
                guard let navigationController = tabbarController.navigationController else { return }
                
                navigationController.view.layer.add(self.openTransition, forKey: nil)
                navigationController.pushViewController(controller, animated: true)
            }
            
            return
        }
        
        showLoading()
        Apphud.paywallsDidLoadCallback { paywalls in
            if let paywall = paywalls.filter({ $0.identifier == Constants.shared.paywallIdentifier }).first {
                Constants.shared.apphudProducts = paywall.products
                Constants.shared.getStoreProducts()
            }
        
            self.hideLoading()
            
            let controller = PaywallConfigurator.instantiateModule()
            controller.isOnboard = isOnboard
            
            if isOnboard {
                guard let navigationController = self.navigationController else { return }
                navigationController.pushViewController(controller, animated: false)
            } else {
                guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
                guard let navigationController = tabbarController.navigationController else { return }
                
                navigationController.view.layer.add(self.openTransition, forKey: nil)
                navigationController.pushViewController(controller, animated: true)
            }
        }
    }
    
    func showAttentionMessage(_ message: String, completion: EmptyBlock? = nil) {
        let form = CustomAlertController()
        form.direction = .center
        form.alertMessage = message
        form.cancelButtonTitle = "common.ok.button.alert".localized()
        form.cancelButtonCompletion = completion
        form.modalPresentationStyle = .overCurrentContext
        self.present(form, animated: true)
    }
    
    func showErrorMessage(_ message: String, completion: EmptyBlock? = nil) {
        let form = CustomAlertController()
        form.direction = .down
        form.alertMessage = message
        form.cancelButtonTitle = "common.ok.button.alert".localized()
        form.cancelButtonCompletion = completion
        form.modalPresentationStyle = .overCurrentContext
        self.present(form, animated: true)
    }
    
    func showConfirmBackForm(onCancel: EmptyBlock? = nil, onSave: EmptyBlock? = nil, onDiscard: EmptyBlock? = nil) {
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.alertMessage = "add.invoice.back.confirm.title.text".localized()
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = onCancel
        
        form.dopButton1Title = "add.invoice.back.confirm.save.button.title".localized()
        form.dopButton1Completion = onSave
        form.dopButton2Title = "add.invoice.back.confirm.discard.button.title".localized()
        form.dopButton2Completion = onDiscard
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
    
    func showEditForm(title: String?, invoice: InvoiceModel, onCancel: EmptyBlock? = nil,
                      onDelete: EmptyBlock? = nil, onDublicate: EmptyBlock? = nil, onSend: EmptyBlock? = nil,
                      onPaid: EmptyBlock? = nil, onUnpaid: EmptyBlock? = nil) {
        
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.alertMessage = title
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = onCancel
        
        form.dopButton1Title = "main.screen.edit.invoice.button1.title".localized()
        form.dopButton1Completion = onSend
        
        form.dopButton2Title = "main.screen.edit.invoice.button2.title".localized()
        form.dopButton2Completion = onDublicate
        
        form.dopButton3Title = "main.screen.edit.invoice.button3.title".localized()
        form.dopButton3Completion = onDelete
        
        if invoice.paidDate == nil {
            form.dopButton4Title = "main.screen.edit.invoice.button4.title".localized()
            form.dopButton4Completion = onPaid
        } else {
            form.dopButton4Title = "main.screen.edit.invoice.button5.title".localized()
            form.dopButton4Completion = onUnpaid
        }
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
    
    func showSelectTemplateForm(onCancel: EmptyBlock? = nil, completion: @escaping (Int) -> Void) {
        
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        let form = CustomAlertController()
        form.direction = .up
        form.cancelButtonTitle = "common.cancel.button.alert".localized()
        form.cancelButtonCompletion = onCancel
        
        form.dopButton1Title = "main.screen.template.label.text".localized() + " 3"
        form.dopButton1Completion = {
            completion(3)
        }
        
        form.dopButton2Title = "main.screen.template.label.text".localized() + " 2"
        form.dopButton2Completion = {
            completion(2)
        }
        
        form.dopButton3Title = "main.screen.template.label.text".localized() + " 1"
        form.dopButton3Completion = {
            completion(1)
        }
        
        form.modalPresentationStyle = .overCurrentContext
        tabbarController.present(form, animated: true)
    }
}
