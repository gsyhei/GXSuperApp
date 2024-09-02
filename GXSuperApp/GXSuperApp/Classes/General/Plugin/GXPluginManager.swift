//
//  GXPluginManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/25.
//

import UIKit

open class GXPluginManager: NSObject {
    private let pluginLock = NSLock()
    
    private var plugins: [String: GXPluginProtocol] = [:]

    private var pluginActions: [String: GXPluginAction] = [:]

    public static let shared: GXPluginManager = GXPluginManager()
    
    public override init() {}
    
    public func register(plugin: GXPluginProtocol, forKey key: String) {
        self.pluginLock.lock()
        self.plugins[key] = plugin
        self.pluginLock.unlock()
    }
    
    public func plugin(key: String) -> GXPluginProtocol? {
        self.pluginLock.lock()
        let plugin = self.plugins[key]
        self.pluginLock.lock()

        return plugin
    }
    
    public func register(pluginAction: @escaping GXPluginAction, forKey key: String) {
        self.pluginLock.lock()
        self.pluginActions[key] = pluginAction
        self.pluginLock.unlock()
    }
    
    public func pluginAction(key: String) -> GXPluginAction? {
        self.pluginLock.lock()
        let pluginAction = self.pluginActions[key]
        self.pluginLock.lock()

        return pluginAction
    }
}
 
public extension GXPluginManager {
    class func register(plugin: GXPluginProtocol, forKey key: String) {
        GXPluginManager.shared.register(plugin: plugin, forKey: key)
    }
    
    class func plugin(key: String) -> GXPluginProtocol? {
        return GXPluginManager.shared.plugin(key: key)
    }
    
    class func register(pluginAction: @escaping GXPluginAction, forKey key: String) {
        GXPluginManager.shared.register(pluginAction: pluginAction, forKey: key)
    }
    
    class func pluginAction(key: String) -> GXPluginAction? {
        return GXPluginManager.shared.pluginAction(key: key)
    }
}
