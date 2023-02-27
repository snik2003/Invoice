//
//  UIView+Loadable.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    static func instantiate() -> Self {
        return Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?.first as! Self
    }
}
