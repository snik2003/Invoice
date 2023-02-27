//
//  CustomAlertController.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit

enum CustomAlertDirection {
    case down
    case up
    case center
}

final class CustomAlertController: BaseViewController {

    var mainViewHeight: CGFloat = 250
    var direction: CustomAlertDirection = .up
    var alertMessage: String?
    
    var cancelButtonTitle: String?
    var dopButton1Title: String?
    var dopButton2Title: String?
    var dopButton3Title: String?
    var dopButton4Title: String?
    
    var cancelButtonCompletion: EmptyBlock?
    var dopButton1Completion: EmptyBlock?
    var dopButton2Completion: EmptyBlock?
    var dopButton3Completion: EmptyBlock?
    var dopButton4Completion: EmptyBlock?
    
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var mainViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var mainViewLeadingConstraint: NSLayoutConstraint!
    //@IBOutlet private weak var mainViewBottomConstraint: NSLayoutConstraint!
    //@IBOutlet private weak var mainViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var textLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var cancelButton: PrimaryButton!
    @IBOutlet private weak var dopButton1: SecondaryButton2!
    @IBOutlet private weak var dopButton2: SecondaryButton2!
    @IBOutlet private weak var dopButton3: SecondaryButton2!
    @IBOutlet private weak var dopButton4: SecondaryButton2!
    
    @IBOutlet private weak var cancelButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dopButton1HeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dopButton2HeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dopButton3HeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dopButton4HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dopButton1TopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dopButton2TopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dopButton3TopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dopButton4TopConstraint: NSLayoutConstraint!
    
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

        setupMessageLabel()
        setupCancelButton()
        setupDopButton(dopButton1, buttonTitle: dopButton1Title, top: dopButton1TopConstraint, height: dopButton1HeightConstraint)
        setupDopButton(dopButton2, buttonTitle: dopButton2Title, top: dopButton2TopConstraint, height: dopButton2HeightConstraint)
        setupDopButton(dopButton3, buttonTitle: dopButton3Title, top: dopButton3TopConstraint, height: dopButton3HeightConstraint)
        setupDopButton(dopButton4, buttonTitle: dopButton4Title, top: dopButton4TopConstraint, height: dopButton4HeightConstraint)
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
        }, completion: { _ in })
    }

    @IBAction func cancelButtonAction() {
        cancelButton.viewTouched {
            self.dismissAlert(animated: true, completion: self.cancelButtonCompletion)
        }
    }
    
    @IBAction func dopButton1Action() {
        dopButton1.viewTouched {
            self.dismissAlert(animated: true, completion: self.dopButton1Completion)
        }
    }
    
    @IBAction func dopButton2Action() {
        dopButton2.viewTouched {
            self.dismissAlert(animated: true, completion: self.dopButton2Completion)
        }
    }
    
    @IBAction func dopButton3Action() {
        dopButton3.viewTouched {
            self.dismissAlert(animated: true, completion: self.dopButton3Completion)
        }
    }
    
    @IBAction func dopButton4Action() {
        dopButton4.viewTouched {
            self.dismissAlert(animated: true, completion: self.dopButton4Completion)
        }
    }
    
    private func dismissAlert(animated: Bool, completion: EmptyBlock?) {
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
    
    private func setupMessageLabel() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        guard let message = alertMessage else {
            textLabel.alpha = 0.0
            textLabelTopConstraint.constant = 0
            textLabelHeightConstraint.isActive = true
            textLabelHeightConstraint.constant = 0
            return
        }
        
        textLabel.text = message
        textLabel.textColor = .black
        textLabel.font = .appSubtitleFont
        textLabelTopConstraint.constant = direction == .down ? 24 + window.safeAreaInsets.top : 24
        textLabelHeightConstraint.isActive = false
        textLabel.alpha = 1.0
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
    }
    
    private func setupDopButton(_ button: SecondaryButton2, buttonTitle: String?, top: NSLayoutConstraint, height: NSLayoutConstraint) {
        guard let title = buttonTitle else {
            button.alpha = 0.0
            button.setTitle(nil, for: .normal)
            top.constant = 0
            height.constant = 0
            return
        }
        
        button.alpha = 1.0
        button.setTitle(title, for: .normal)
        top.constant = 12
        height.constant = 52
    }
    
    private func setupMainView() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        mainView.clipsToBounds = true
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 0
        
        switch direction {
        case .center:
            mainView.layer.cornerRadius = 8
            mainViewLeadingConstraint.constant = 40
            cancelButtonBottomConstraint.constant = 24
        case .up:
            mainView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
            mainViewLeadingConstraint.constant = 0
            cancelButtonBottomConstraint.constant = 24 + window.safeAreaInsets.bottom
        case .down:
            mainView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
            mainViewLeadingConstraint.constant = 0
            cancelButtonBottomConstraint.constant = 24
        }
        
    }
}
