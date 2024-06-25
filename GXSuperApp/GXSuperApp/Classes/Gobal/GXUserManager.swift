//
//  GXUserManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/25.
//

import UIKit

class GXUserManager: NSObject {
    static let shared: GXAppleManager = {
        let instance = GXAppleManager()
        return instance
    }()

    /// 登录相关
    var token: String?
    var isLogin: Bool {
        return self.token != nil
    }
    
    /// 全局筛选配置model
    lazy var filter: GXHomeFilterModel = {
        return GXHomeFilterModel()
    }()
    
}
