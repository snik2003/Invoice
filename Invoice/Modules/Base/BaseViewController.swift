//
//  BaseViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var openTransition: CATransition {
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        return transition
    }
    
    var closeTransition: CATransition {
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        return transition
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        guard self is LaunchViewController else { return .darkContent }
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .appBackgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.updateBottomConstraints()
    }
    
    func updateBottomConstraints() {
        guard let bottomConstraint = self.bottomConstraint else { return }
        guard let tabbarController = self.tabBarController as? BaseTabBarController else { return }
        
        if self is ReportsViewController || self is SettingsViewController || self is PreviewViewController {
            bottomConstraint.constant = tabbarController.tabbarDifference
            return
        }
        
        bottomConstraint.constant = tabbarController.tabbarDifference + 24
    }
    
    func setupRootViewController(isOnboard: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        if isOnboard {
            appDelegate.setupRootViewController()
        } else if let navigationController = self.navigationController, navigationController.viewControllers.count == 1 {
            appDelegate.setupRootViewController()
        } else {
            closeViewControllerAction()
        }
    }
    
    func closeViewControllerAction(animated: Bool = true) {
        self.navigationController?.view.layer.add(closeTransition, forKey: nil)
        self.navigationController?.popViewController(animated: animated)
    }
    
    func dismissPresentedViewController(animated: Bool, completion: @escaping EmptyBlock) {
        guard let controller = BaseViewController.topPresentedController as? UIAlertController else { completion(); return }
        controller.dismiss(animated: true, completion: completion)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func exportInvoiceToPDF(with template: Int, model: InvoiceModel, client: ClientModel, presenter: MainViewOutput,
                           completion: @escaping (NSData?,URL?) -> Void) {
        
        showLoading()
        PDFManager.shared.exportInvoiceToPDF(model, client: client, presenter: presenter, template: template) { data, url, error in
            self.hideLoading()
            
            if let error = error {
                self.showErrorMessage(error)
                return
            }
            
            completion(data,url)
        }
    }
}

extension BaseViewController {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle: nil)
    }
    
    static var topPresentedController: UIViewController? {
        get {
            var presentingController = UIApplication.shared.keyWindow?.rootViewController
            while let presentedController = presentingController?.presentedViewController, !presentedController.isBeingDismissed {
                presentingController = presentedController
            }
            return presentingController
        }
    }
}

extension UINavigationController {
    
    func popViewController(animated: Bool, completion: EmptyBlock?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        popViewController(animated: animated)
        
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool, completion: EmptyBlock?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        popToRootViewController(animated: animated)
        
        CATransaction.commit()
    }
}

extension BaseViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.navigationController!
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        hideLoading()
    }
}
