//
//  AppDelegate.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/4.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let navc = UINavigationController(rootViewController: ViewController())
        self.setWindowRootViewController(to: navc)
        return true
    }

}

extension AppDelegate {
    func setWindowRootViewController(to viewController: UIViewController) {
        guard self.window?.rootViewController != nil else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.backgroundColor = UIColor.black
            self.window?.rootViewController = viewController;
            self.window?.makeKeyAndVisible()
            return
        }
        viewController.modalTransitionStyle = .crossDissolve
        UIView.transition(with: self.window!, duration: 1.0, options: .transitionCrossDissolve, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.window?.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: nil)
    }
}
