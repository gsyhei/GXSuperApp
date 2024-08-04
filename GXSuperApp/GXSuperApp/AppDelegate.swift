//
//  AppDelegate.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/4.
//

import UIKit
import XCGLogger
import Bugly
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import SkeletonView
import StripeCore

let GXAppDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 日志级别
        XCGLogger.default.outputLevel = .verbose
        
        // 注册Bugly
        Bugly.start(withAppId: GX_BUGLY_APPID)
        
        // 开启键盘管理
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.disabledToolbarClasses.append(GXHomeDetailAddVehicleVC.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(GXHomeDetailAddVehicleVC.self)
        
        // 配置过渡
        SkeletonAppearance.default.gradient = SkeletonGradient(baseColor: .gx_lineGray)
        SkeletonAppearance.default.skeletonCornerRadius = 3.0
        
        // 谷歌地图
        GMSServices.provideAPIKey(GX_GOOGLE_APIKEY)
        GMSPlacesClient.provideAPIKey(GX_GOOGLE_APIKEY)
        
        // 主题预设
        UIApplication.shared.applicationIconBadgeNumber = 0
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.gx_black
        let nbAppearance = UINavigationBarAppearance()
        nbAppearance.configureWithTransparentBackground()
        nbAppearance.backgroundColor = UIColor.white
        nbAppearance.shadowColor = .gx_lightGray
        nbAppearance.titleTextAttributes = [.foregroundColor: UIColor.gx_black, .font: UIFont.gx_boldFont(size: 19)]
        let bbiAppearance = UIBarButtonItemAppearance(style: .plain)
        bbiAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gx_black, .font: UIFont.gx_boldFont(size: 15)]
        bbiAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.gx_gray, .font: UIFont.gx_boldFont(size: 15)]
        nbAppearance.buttonAppearance = bbiAppearance
        nbAppearance.doneButtonAppearance = bbiAppearance
        nbAppearance.backButtonAppearance = bbiAppearance
        UINavigationBar.appearance().standardAppearance = nbAppearance
        if #available(iOS 15.0, *) {
            let nbAppearance = UINavigationBarAppearance()
            nbAppearance.configureWithTransparentBackground()
            //nbAppearance.backgroundColor = UIColor.white //这个属性不设置为导航透明
            nbAppearance.titleTextAttributes = [.foregroundColor: UIColor.gx_black, .font: UIFont.gx_boldFont(size: 19)]
            let bbiAppearance = UIBarButtonItemAppearance(style: .plain)
            bbiAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gx_black, .font: UIFont.gx_boldFont(size: 15)]
            bbiAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.gx_gray, .font: UIFont.gx_boldFont(size: 15)]
            nbAppearance.buttonAppearance = bbiAppearance
            nbAppearance.doneButtonAppearance = bbiAppearance
            nbAppearance.backButtonAppearance = bbiAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = nbAppearance
        }
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor = .gx_lightGray
        let tbiAppearance = UITabBarItemAppearance(style: .stacked)
        tbiAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gx_drakGray, .font: UIFont.gx_font(size: 13)]
        tbiAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.gx_green, .font: UIFont.gx_boldFont(size: 13)]
        tbiAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        tbiAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        appearance.stackedLayoutAppearance = tbiAppearance
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.white
            let tbiAppearance = UITabBarItemAppearance(style: .stacked)
            tbiAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gx_drakGray, .font: UIFont.gx_font(size: 13)]
            tbiAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.gx_green, .font: UIFont.gx_boldFont(size: 13)]
            tbiAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
            tbiAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
            appearance.stackedLayoutAppearance = tbiAppearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        let vc = GXLaunchScreenVC.xibViewController()
        self.setWindowRootViewController(to: vc)
        
        return true
    }
    
    // MARK: - UIApplicationDelegate
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if StripeAPI.handleURLCallback(with: url) {
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did fail to register for remote notification with error ", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
}

extension AppDelegate {
    func setWindowRootViewController(to viewController: UIViewController) {
        guard self.window?.rootViewController != nil else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.backgroundColor = UIColor.gx_background
            self.window?.rootViewController = viewController;
            self.window?.makeKeyAndVisible()
            return
        }
        viewController.modalTransitionStyle = .crossDissolve
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.window?.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: nil)
    }
    func gotoLogin(from: UIViewController, completion: GXActionBlock? = nil) {
        let vc = GXLoginPhoneVC.xibViewController()
//        vc.completion = completion
        let navc = GXBaseNavigationController(rootViewController: vc)
        navc.modalPresentationStyle = .fullScreen
        from.present(navc, animated: true)
    }
    func gotoMainTabbarController(index: Int = 0) {
        let vc = GXTabBarController()
        vc.selectedIndex = index
        self.setWindowRootViewController(to: vc)
    }
    func logout(index: Int = 0) {
        self.gotoMainTabbarController(index: index)
    }
}
