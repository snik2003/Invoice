//
//  PrimaryButton.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

final class PrimaryButton: UIButton {
    
    override var isEnabled: Bool {
        didSet { handleState() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEnabled = true
        setupStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setBackgroundColor()
        setShadow()
    }
    
    func setBackgroundColor() {
        self.backgroundColor = isEnabled ? .appPrimaryColor : .appHintColor
        self.setTitleColor(isEnabled ? .white : .black, for: .highlighted)
        self.setTitleColor(isEnabled ? .white : .black, for: .normal)
        layer.borderWidth = isEnabled ? 0.0 : 0.0
    }
    
    private func setupStyle() {
        setBackgroundColor()
        setCornerRadius(radius: 12)
        setShadow()
        
        titleLabel?.font = .appButtonFont
        titleLabel?.textColor = isEnabled ? .white : .black
        
        setTitleColor(isEnabled ? .white : .black, for: .highlighted)
        setTitleColor(isEnabled ? .white : .black, for: .normal)
    }
    
    private func handleState() {
        let animations: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.setBackgroundColor()
        }
        
        UIView.animate(withDuration: 0.3, animations: animations)
    }
    
    private func setShadow() {
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 12.0
        layer.masksToBounds = false
    }
}


