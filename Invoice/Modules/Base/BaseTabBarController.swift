//
//  BaseTabBarController.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

import UIKit

class BaseTabBarController: UITabBarController {
    
    let tabbarHeight: CGFloat = 90
    
    private lazy var defaultTabBarHeight = { [unowned self] in
        return self.tabBar.frame.size.height
    }()
    
    var tabbarDifference: CGFloat = 0
    
    override var selectedIndex: Int {
        didSet {
            guard let selectedViewController = viewControllers?[selectedIndex] else { return }
            
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.appCaptionFont]
            selectedViewController.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        }
    }
    
    override var selectedViewController: UIViewController? {
        didSet {
            guard let viewControllers = viewControllers else { return }
            
            for viewController in viewControllers {
                let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.appCaptionFont]
                viewController.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeHeight()
        changeDesign()
    }
    
    func changeHeight() {
        tabbarDifference = tabbarHeight - defaultTabBarHeight
        
        var newFrame = tabBar.frame
        newFrame.size.height = tabbarHeight
        newFrame.origin.y = view.frame.size.height - tabbarHeight

        tabBar.frame = newFrame
        
        tabBar.items?.forEach({ item in
            let offset = self.tabbarDifference / 4
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: offset)
            
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.appCaptionFont]
            item.setTitleTextAttributes(attributes, for: .normal)
        })
    }
    
    func changeDesign() {
        self.view.backgroundColor = .appBackgroundColor
        tabBar.backgroundColor = .white
        tabBar.tintColor = .appPrimaryColor
        tabBar.unselectedItemTintColor = .appCaptionColor
        
        tabBar.layer.cornerRadius = 16
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        tabBar.layer.shadowRadius = 16
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        tabBar.layer.shadowOpacity = 0.9
        
        self.view.layoutIfNeeded()
    }
}
