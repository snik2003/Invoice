//
//  Onboard1ViewController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol Onboard1ViewInput: BaseViewInput {
    func setupInitialState()
}

class Onboard1ViewController: BaseViewController {

    var presenter: Onboard1ViewOutput?
    
    @IBOutlet weak var nextButton: PrimaryButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
    }
    
    @IBAction func nextButtonAction() {
        guard let bussinessName = textField.text, !bussinessName.isEmpty else { return }
        presenter?.setBussinessName(bussinessName)
        
        nextButton.viewTouched {
            let controller = Onboard2Configurator.instantiateModule()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension Onboard1ViewController: Onboard1ViewInput {
    func setupInitialState() {
        nextButton.setTitle("onboard.screen.next.button.title".localized(), for: .normal)
        nextButton.isEnabled = false
        
        titleLabel.text = "onboard.screen.onboard1.title.text".localized()
        titleLabel.textColor = .black
        titleLabel.font = .appTitleFont
        
        subtitleLabel.text = "onboard.screen.onboard1.hint.text".localized()
        subtitleLabel.textColor = .black
        subtitleLabel.font = .appSubtitleFont
        
        setupTextField()
        nextButton.isEnabled = presenter?.bussinessName() != nil
    }
    
    func setupTextField() {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.appHintColor, .font : UIFont.appSubtitleFont]
        
        textField.clipsToBounds = true
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        
        textField.textColor = .black
        textField.font = .appSubtitleFont
        textField.placeholder = "onboard.screen.onboard1.placeholder.text".localized()
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: attributes)
        
        textField.text = presenter?.bussinessName()
        textField.delegate = self
    }
}

extension Onboard1ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        nextButton.isEnabled = !text.isEmpty
    }
}
