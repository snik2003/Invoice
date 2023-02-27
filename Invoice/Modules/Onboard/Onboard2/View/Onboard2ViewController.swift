//
//  Onboard2ViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

import UIKit

protocol Onboard2ViewInput: BaseViewInput {
    func setupInitialState()
}

class Onboard2ViewController: BaseViewController {

    var presenter: Onboard2ViewOutput?
    
    @IBOutlet weak var nextButton: PrimaryButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    @IBAction func nextButtonAction() {
        nextButton.viewTouched {
            self.presenter?.setupFirstLaunch()
            self.openPaywall(isOnboard: true)
        }
    }
}

extension Onboard2ViewController: Onboard2ViewInput {
    func setupInitialState() {
        nextButton.setTitle("onboard.screen.next.button.title".localized(), for: .normal)
        
        titleLabel.text = "onboard.screen.onboard2.title.text".localized()
        titleLabel.textColor = .black
        titleLabel.font = .appTitleFont
        
        subtitleLabel.text = "onboard.screen.onboard2.hint.text".localized()
        subtitleLabel.textColor = .black
        subtitleLabel.font = .appSubtitleFont
        
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 12
        iconView.backgroundColor = .white
    }
}
