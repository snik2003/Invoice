//
//  Onboard2Presenter.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit
//import OneSignal
//import ApphudSDK

protocol Onboard2ViewOutput: BaseViewOutput {
    func viewLoaded()
    func pushRequest()
    func setupFirstLaunch()
}

final class Onboard2Presenter: BasePresenter {
    
    weak var view: Onboard2ViewInput?
    private var appDataService: AppDataServiceProtocol
    
    init(appDataService: AppDataServiceProtocol = serviceLocator.getService()) {
        self.appDataService = appDataService
    }
}

extension Onboard2Presenter: Onboard2ViewOutput {
    
    func viewLoaded() {
        view?.setupInitialState()
    }
    
    func setupFirstLaunch() {
        appDataService.firstLaunch = false
    }
    
    func pushRequest() {
        /*OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notification: \(accepted)")
        })
        
        OneSignal.setExternalUserId(Apphud.userID())*/
    }
}

