//
//  GXBaseNavigationController.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/6/2.
//

import UIKit
import XCGLogger

class GXBaseNavigationController: UINavigationController, UINavigationControllerDelegate {
    var popDelegate: UIGestureRecognizerDelegate?
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.topViewController?.prefersStatusBarHidden ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        self.popDelegate = self.interactivePopGestureRecognizer?.delegate
        self.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isBeingDismissed {
            self.viewControllers.forEach { vc in
                if let baseVc = vc as? GXBaseViewController {
                    baseVc.viewDidDisappearPopOrDismissed(animated)
                }
            }
        }
    }
    
    // MARK: - UINavigationControllerDelegate方法
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self.viewControllers.first {
            self.interactivePopGestureRecognizer?.delegate = self.popDelegate
        }
        else {
            self.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if viewControllers.count > 1 {
            viewControllers.last?.hidesBottomBarWhenPushed = true
        }
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
}

