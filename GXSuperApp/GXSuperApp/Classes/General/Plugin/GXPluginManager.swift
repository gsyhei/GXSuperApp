//
//  GXPluginManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/25.
//

import UIKit

open class GXPluginManager: NSObject {
    
    private var plugins: [String: GXPluginProtocol] = [:]

    private var pluginActions: [String: GXPluginAction] = [:]

    public static let shared: GXPluginManager = GXPluginManager()
    
    public override init() {}
    
    public class func register(plugin: GXPluginProtocol, forKey key: String) {
        GXPluginManager.shared.plugins[key] = plugin
    }
    
    public class func plugin(key: String) -> GXPluginProtocol? {
        return GXPluginManager.shared.plugins[key]
    }
    
    public class func register(pluginAction: @escaping GXPluginAction, forKey key: String) {
        GXPluginManager.shared.pluginActions[key] = pluginAction
    }
    
    public class func pluginAction(key: String) -> GXPluginAction? {
        return GXPluginManager.shared.pluginActions[key]
    }
    
}
