//
//  GXPluginManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/25.
//

import UIKit

public class GXPluginManager: NSObject {
    
    private var plugins: [String: GXPluginProtocol] = [:]

    public static let shared: GXPluginManager = GXPluginManager()
    
    public override init() {}
    
    public func register(plugin: GXPluginProtocol, forKey key: String) {
        self.plugins[key] = plugin
    }
    
    public func plugin(key: String) -> GXPluginProtocol? {
        return self.plugins[key]
    }
    
}
