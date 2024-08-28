//
//  GXPluginProtocol.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/24.
//

import UIKit

public typealias GXPluginAction = (([String: Any]) -> Void)

public protocol GXPluginProtocol {
    
    func param(key: String) -> [String: Any]?
        
    func createView(key: String, param: [String: Any]) -> UIView?
    
    func createViewController(key: String, param: [String: Any]) -> UIViewController?
    
    func push(from: UIViewController, key: String, param: [String: Any], animated flag: Bool)
    
    func present(from: UIViewController, toNavc: UINavigationController?, key: String, param: [String: Any], animated flag: Bool)
    
    func eventAction(key: String) -> GXPluginAction?
    
}
