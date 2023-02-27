//
//  UIButton+Extension.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

extension UIButton {
    
    open override func awakeFromNib() {
        self.setTitle("", for: .normal)
        super.awakeFromNib()
    }
}
