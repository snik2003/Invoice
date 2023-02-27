//
//  CustomSearchController.swift
//  Invoice
//
//  Created by Сергей Никитин on 02.12.2022.
//

import UIKit

final class CustomSearchController: BaseViewController {

    var mainViewHeight: CGFloat = 250
    var direction: CustomAlertDirection = .up
    
    var cancelButtonTitle: String?
    var dopButtonTitle: String?
    var searchBarText: String?
    var searchBarPlaceholder: String?
    
    var cancelButtonCompletion: EmptyBlock?
    var dopButtonCompletion: SearchValueBlock?
    
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var mainViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var mainViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var cancelButton: PrimaryButton!
    @IBOutlet private weak var dopButton: SecondaryButton!
    
    @IBOutlet private weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cancelButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dopButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dopButtonTopConstraint: NSLayoutConstraint!
    
    private var centerShowConstant: CGFloat {
        switch direction {
        case .down:
            return -UIScreen.main.bounds.height/2 + mainViewHeight/2
        case .up:
            return UIScreen.main.bounds.height/2 - mainViewHeight/2
        default:
            return 0
        }
    }
    
    private var centerHideConstant: CGFloat {
        switch direction {
        case .up:
            return UIScreen.main.bounds.height
        default:
            return -1 * UIScreen.main.bounds.height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCancelButton()
        setupSearchBar()
        setupDopButton()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupMainView()
        mainViewHeight = mainView.bounds.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .clear
        mainView.alpha = 0.0
        mainViewCenterConstraint.constant = centerHideConstant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let options: UIView.AnimationOptions = direction == .down ? .transitionFlipFromTop : .transitionFlipFromBottom
        
        UIView.transition(with: mainView, duration: 0.3, options: options, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.mainViewCenterConstraint.constant = self.centerShowConstant
            self.mainView.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.searchBar.becomeFirstResponder()
        })
    }

    @IBAction func cancelButtonAction() {
        cancelButton.viewTouched {
            self.dismissAlert(animated: true, completion: self.cancelButtonCompletion)
        }
    }
    
    @IBAction func dopButtonAction() {
        guard let value = searchBar.text, !value.isEmpty else { return }
        
        dopButton.viewTouched {
            self.dismissAlert(animated: true) {
                self.dopButtonCompletion?(value)
            }
        }
    }
    
    private func dismissAlert(animated: Bool, completion: EmptyBlock?) {
        searchBar.resignFirstResponder()
        let options: UIView.AnimationOptions = direction == .down ? .transitionFlipFromBottom : .transitionFlipFromTop
        
        UIView.transition(with: mainView, duration: 0.3, options: options, animations: {
            self.view.backgroundColor = .clear
            self.mainViewCenterConstraint.constant = self.centerHideConstant
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.mainView.alpha = 0.0
            self.dismiss(animated: animated, completion: completion)
        })
    }

    private func setupSearchBar() {
        searchBar.text = searchBarText
        searchBar.keyboardAppearance = .light
        searchBar.barTintColor = .white
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 12
        searchBar.layer.borderWidth = 0
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .black
        searchBar.placeholder = searchBarPlaceholder ?? "main.screen.search.bar.placeholder.text".localized()
        searchBar.setClearTextImage(image: UIImage(named: "close2"))
        searchBar.setSearchImage(image: UIImage(named: "search2"))
                
        searchBar.searchTextField.textColor = .black
        searchBar.searchTextField.font = .appSubtitleFont
        searchBar.setTextField(color: .white, cornerRadius: 12)
        
        searchBar.delegate = self
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
    }
    
    private func setupDopButton() {
        guard let title = dopButtonTitle else {
            dopButton.alpha = 0.0
            dopButton.setTitle(nil, for: .normal)
            dopButtonTopConstraint.constant = 0
            dopButtonHeightConstraint.constant = 0
            return
        }
        
        dopButton.alpha = 1.0
        dopButton.setTitle(title, for: .normal)
        dopButtonTopConstraint.constant = 12
        dopButtonHeightConstraint.constant = 52
        dopButton.isEnabled = !(searchBarText ?? "").isEmpty
    }
    
    private func setupMainView() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        mainView.clipsToBounds = true
        mainView.backgroundColor = .appBackgroundColor
        mainView.layer.cornerRadius = 0
        
        switch direction {
        case .center:
            mainView.layer.cornerRadius = 8
            mainViewLeadingConstraint.constant = 40
            cancelButtonBottomConstraint.constant = 24
            searchBarTopConstraint.constant = 24
        case .up:
            mainView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
            mainViewLeadingConstraint.constant = 0
            cancelButtonBottomConstraint.constant = 24 + window.safeAreaInsets.bottom
            searchBarTopConstraint.constant = 24
        case .down:
            mainView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
            mainViewLeadingConstraint.constant = 0
            cancelButtonBottomConstraint.constant = 24
            searchBarTopConstraint.constant = 24 + window.safeAreaInsets.top
        }
    }
}

extension CustomSearchController: UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else {
            dopButton.isEnabled = false
            return
        }
        
        dopButton.isEnabled = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let value = searchBar.text, !value.isEmpty else { return }
        dismissAlert(animated: true) {
            self.dopButtonCompletion?(value)
        }
    }
}
