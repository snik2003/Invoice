//
//  AppDelegate.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit
import CoreData
import StoreKit
import IQKeyboardManager

import iAd
import AdServices

//import OneSignal
import ApphudSDK
import FirebaseCore
import FirebaseAnalytics
import YandexMobileMetrica

var serviceLocator: ServiceLocator!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var coreDataStack: CoreDataStack = .init(modelName: "AppModel")

    static let shared: AppDelegate = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unexpected app delegate type, did it change? \(String(describing: UIApplication.shared.delegate))")
        }
        
        return delegate
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().toolbarTintColor = .appPrimaryColor
        
        //setupAppHudServices()
        //setupYandexServices()
        //setupFirebaseServices()
        //setupOneSignalServices(launchOptions: launchOptions)
        
        setupLocalServices()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppDelegate.shared.coreDataStack.saveContext()
    }
}

extension AppDelegate {
    
    func setupLocalServices() {
        let registry = LazyServiceLocator()
        serviceLocator = registry

        var appDataService: AppDataServiceProtocol = AppDataService()
        appDataService.isPremiumMode = Apphud.hasPremiumAccess()
    
        if Constants.shared.isTestMode {
            //appDataService.firstLaunch = true
            //appDataService.bussinessName = nil
            //appDataService.isPremiumMode = true
            //appDataService.invoiceNumber = 1
            appDataService.firstInvoice1 = true
            appDataService.firstInvoice2 = true
            appDataService.firstInvoice3 = true
        }
        
        registry.addService { appDataService }
        
        setupLaunchViewController()
        
        if appDataService.firstLaunch {
            setupOnboardViewController()
        } else if appDataService.isPremiumMode {
            setupRootViewController()
        } else {
            setupPaywallViewController()
        }
    }
    
    func setupLaunchViewController() {
        guard let window = window else { return }
                
        let viewController = LaunchViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func setupOnboardViewController() {
        guard let window = window else { return }
                
        let controller = Onboard1Configurator.instantiateModule()
        let navigationController = UINavigationController()
        navigationController.viewControllers = [controller]
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func setupPaywallViewController() {
        guard let window = window else { return }
        
        guard !Constants.shared.isTestMode else {
            Constants.shared.getStoreProducts()
            
            let controller = PaywallConfigurator.instantiateModule()
            controller.products = PSKProduct.getDemoProducts()
            controller.isOnboard = true
            
            let navigationController = UINavigationController()
            navigationController.viewControllers = [controller]
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
            return
        }
        
        Apphud.paywallsDidLoadCallback { paywalls in
            if let paywall = paywalls.filter({ $0.identifier == Constants.shared.paywallIdentifier }).first {
                Constants.shared.apphudProducts = paywall.products
                Constants.shared.getStoreProducts()
            }
        
            let controller = PaywallConfigurator.instantiateModule()
            let navigationController = UINavigationController()
            navigationController.viewControllers = [controller]
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
    
    func setupRootViewController() {
        guard let window = self.window else { return }
                    
        let controller1 = MainConfigurator.instantiateModule()
        let controller2 = ClientsConfigurator.instantiateModule()
        let controller3 = ItemsConfigurator.instantiateModule()
        let controller4 = ReportsConfigurator.instantiateModule()
        let controller5 = SettingsConfigurator.instantiateModule()
                
        let tabController1 = UINavigationController()
        tabController1.navigationBar.isTranslucent = false
        tabController1.viewControllers = [controller1]
        tabController1.tabBarItem = UITabBarItem(title: "main.screen.tabbar1.title".localized(),
                                                 image: UIImage(named: "tabbar1"), tag: 0)
                
        let tabController2 = UINavigationController()
        tabController2.navigationBar.isTranslucent = false
        tabController2.viewControllers = [controller2]
        tabController2.tabBarItem = UITabBarItem(title: "main.screen.tabbar2.title".localized(),
                                                 image:  UIImage(named: "tabbar2"), tag: 1)
                
        let tabController3 = UINavigationController()
        tabController3.navigationBar.isTranslucent = false
        tabController3.viewControllers = [controller3]
        tabController3.tabBarItem = UITabBarItem(title: "main.screen.tabbar3.title".localized(),
                                                 image:  UIImage(named: "tabbar3"), tag: 2)
        
        let tabController4 = UINavigationController()
        tabController4.navigationBar.isTranslucent = false
        tabController4.viewControllers = [controller4]
        tabController4.tabBarItem = UITabBarItem(title: "main.screen.tabbar4.title".localized(),
                                                 image:  UIImage(named: "tabbar4"), tag: 3)
        
        let tabController5 = UINavigationController()
        tabController5.navigationBar.isTranslucent = false
        tabController5.viewControllers = [controller5]
        tabController5.tabBarItem = UITabBarItem(title: "main.screen.tabbar5.title".localized(),
                                                 image:  UIImage(named: "tabbar5"), tag: 5)
                
        
        let tabbarController = BaseTabBarController()
        tabbarController.viewControllers = [tabController1, tabController2, tabController3, tabController4, tabController5]
        
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        navigationController.viewControllers = [tabbarController]
        navigationController.navigationBar.isTranslucent = false
          
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension AppDelegate {
    
    fileprivate func setupAppHudServices() {
        
        Apphud.start(apiKey: Constants.shared.appHudApiKey)
        Apphud.setDelegate(self)
        
        trackAppleSearchAds()
        
        guard Constants.shared.isTestMode else { return }
        print("APPHUD SERVICES 🛍")
    }
    
    fileprivate func setupYandexServices() {
        
        guard !Constants.shared.isTestMode else {
            print("YANDEX METRICA 🔔")
            return
        }
        
        
        if let configuration = YMMYandexMetricaConfiguration(apiKey: Constants.shared.appMetrikaApiKey) {
            YMMYandexMetrica.activate(with: configuration)
            YMMYandexMetrica.setUserProfileID(Apphud.userID())
        }
    }
    
    fileprivate func setupFirebaseServices() {
        
        guard !Constants.shared.isTestMode else {
            print("GOOGLE FIREBASE 🧲")
            return
        }
        
        FirebaseApp.configure()
        
        Analytics.setUserID(Apphud.userID())
        if let instanceID = Analytics.appInstanceID() {
            Apphud.addAttribution(data: nil, from: .firebase, identifer: instanceID,  callback: nil)
        }
    }
    
    fileprivate func setupOneSignalServices(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        guard !Constants.shared.isTestMode else {
            print("ONE SIGNAL 💬")
            return
        }
        
        //OneSignal.initWithLaunchOptions(launchOptions)
        //OneSignal.setAppId(Constants.shared.oneSignalAppID)
        //OneSignal.setExternalUserId(Apphud.userID())
    }
    
    
    fileprivate func trackAppleSearchAds() {
        if #available(iOS 14.3, *) {
            DispatchQueue.global(qos: .default).async {
                if let token = try? AAAttribution.attributionToken() {
                    DispatchQueue.main.async {
                        Apphud.addAttribution(data: nil, from: .appleAdsAttribution, identifer: token, callback: nil)
                    }
                }
            }
        } else {
            ADClient.shared().requestAttributionDetails { data, _ in
                data.map { Apphud.addAttribution(data: $0, from: .appleSearchAds, callback: nil) }
            }
        }
    }
}

extension AppDelegate: ApphudDelegate {
    
    func apphudDidFetchStoreKitProducts(_ products: [SKProduct]) {
        print("appHud products count = \(products.count)")
    }

    func apphudDidFetchStoreKitProducts(_ products: [SKProduct], _ error: Error?) {
        guard let error = error else { return }
        print("appHud products error = \(error.localizedDescription)")
    }

    func apphudDidObservePurchase(result: ApphudPurchaseResult) -> Bool {
        print("Did observe purchase made without Apphud SDK: \(result)")
        return true
    }
    
    func apphudShouldStartAppStoreDirectPurchase(_ product: SKProduct) -> ((ApphudPurchaseResult) -> Void)? {
        let callback : ((ApphudPurchaseResult) -> Void) = { [weak self] result in
            guard let self = self else { return }
            
            var appDataService: AppDataServiceProtocol = serviceLocator.getService()
            appDataService.isPremiumMode = Apphud.hasPremiumAccess()
            self.setupRootViewController()
        }
        
        return callback
    }
}
