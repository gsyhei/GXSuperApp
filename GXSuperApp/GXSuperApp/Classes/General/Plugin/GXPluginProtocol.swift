//
//  GXPluginProtocol.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/24.
//

import UIKit

public protocol GXPluginProtocol {
    
    var parameters: [String: [String: Any]] { get }
    
    func createView(key: String, param: [String: Any]) -> UIView
    
    func createViewController(key: String, param: [String: Any]) -> UIViewController
    
    func pushViewController(from: UIViewController, key: String, param: [String: Any]) -> UIViewController
    
}

