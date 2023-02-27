//
//  UISearchBar+Extension.swift
//  Invoice
//
//  Created by Сергей Никитин on 02.12.2022.
//

import UIKit

extension UISearchBar {
    func clearBackgroundColor() {
        for view in self.subviews {
            view.backgroundColor = UIColor.clear
            for subview in view.subviews {
                subview.backgroundColor = UIColor.clear
            }
        }
    }
    
    func getTextField() -> UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            if let searchField = self.value(forKey: "_searchField") as? UITextField {
                return searchField
            } else if let searchField = self.value(forKey: "searchField") as? UITextField {
                return searchField
            }
        }
        
        return nil
    }
    
    func setTextField(color: UIColor, cornerRadius: CGFloat) {
        let differentColorSearchBar = UIView(frame: bounds)

        differentColorSearchBar.layer.cornerRadius = cornerRadius
        differentColorSearchBar.clipsToBounds = true
        differentColorSearchBar.backgroundColor = color

        let image = differentColorSearchBar.asImage()
        self.setSearchFieldBackgroundImage(image, for: .highlighted)
        self.setSearchFieldBackgroundImage(image, for: .normal)
    }
    
    func removeLeftView() {
        guard let textField = self.getTextField() else { return }
        textField.leftViewMode = .never
    }
    
    func setClearTextImage(image: UIImage?) {
        self.setImage(image, for: .clear, state: .highlighted)
        self.setImage(image, for: .clear, state: .normal)
    }
    
    func setSearchImage(image: UIImage?) {
        self.setImage(image, for: .search, state: .highlighted)
        self.setImage(image, for: .search, state: .normal)
    }
}
