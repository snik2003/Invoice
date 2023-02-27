//
//  UITextField+Extension.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

extension UITextField {
    
    func setClearButtonImage(image: UIImage?) {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .center
        
        button.setImage(image, for: .highlighted)
        button.setImage(image, for: .normal)
        
        button.frame = CGRect(x: bounds.width - 24, y: (bounds.height - 24) / 2, width: 24, height: 24)
        button.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        
        rightView = button
        rightViewMode = self.clearButtonMode
    }
    
    @objc func clearAction() {
        guard let button = rightView as? UIButton else { return }
        
        button.viewTouched {
            self.text = nil
            self.becomeFirstResponder()
        }
    }
}
