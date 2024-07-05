//
//  GXChargingStoryboard.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/5.
//

import UIKit
import Reusable

protocol GXChargingStoryboard: StoryboardBased {}

extension GXChargingStoryboard {
    static var sceneStoryboard: UIStoryboard {
        return UIStoryboard(name: "GXCharging", bundle: Bundle(for: self))
    }
}

// MARK: Support for instantiation from Storyboard

extension GXChargingStoryboard where Self: UIViewController {
    static func instantiate() -> Self {
        let viewController = sceneStoryboard.instantiateViewController(withIdentifier: String(describing: self))
        guard let typedViewController = viewController as? Self else {
            fatalError("The initialViewController of '\(sceneStoryboard)' is not of class '\(self)'")
        }
        return typedViewController
    }
}
