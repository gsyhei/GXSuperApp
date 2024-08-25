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
    
    public class func register(plugin: GXPluginProtocol, forKey key: String) {
        GXPluginManager.shared.plugins[key] = plugin
    }
    
    public class func plugin(key: String) -> GXPluginProtocol? {
        return GXPluginManager.shared.plugins[key]
    }
    
}
