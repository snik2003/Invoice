//
//  SecondaryButton2.swift
//  Invoice
//
//  Created by Сергей Никитин on 29.11.2022.
//

import UIKit

final class SecondaryButton2: UIButton {
    
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
        self.backgroundColor = .appBackgroundColor
        self.setTitleColor(isEnabled ? .appPrimaryColor : .appHintColor, for: .highlighted)
        self.setTitleColor(isEnabled ? .appPrimaryColor : .appHintColor, for: .normal)
        layer.borderWidth = 0.0
    }
    
    private func setupStyle() {
        setBackgroundColor()
        setCornerRadius(radius: 12)
        setShadow()
        
        titleLabel?.font = .appButtonFont
        titleLabel?.textColor = isEnabled ? .appPrimaryColor : .appHintColor
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
        layer.shadowColor = UIColor.appHintColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 12.0
        layer.masksToBounds = false
    }
}

