//
//  LoadingViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit

class LoadingViewController {
    
    private static var container: UIView = UIView()
    private static var loadingView: UIImageView = UIImageView()
    
    func showLoading(view: UIView) {
        OperationQueue.main.addOperation {
            LoadingViewController.container.frame = view.frame
            LoadingViewController.container.center = view.center
            LoadingViewController.container.backgroundColor = .clear
            
            LoadingViewController.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            LoadingViewController.loadingView.image = UIImage(named: "loading")
            LoadingViewController.loadingView.tintColor = .appPrimaryColor
            LoadingViewController.loadingView.clipsToBounds = true
            LoadingViewController.loadingView.center = view.center
            LoadingViewController.loadingView.rotate()
            
            LoadingViewController.container.addSubview(LoadingViewController.loadingView)
            view.addSubview(LoadingViewController.container)
        }
    }
    
    func hideLoading() {
        OperationQueue.main.addOperation {
            LoadingViewController.container.removeFromSuperview()
        }
    }
}

