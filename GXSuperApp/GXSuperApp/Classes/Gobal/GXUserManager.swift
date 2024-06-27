//
//  GXUserManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/25.
//

import UIKit

class GXUserManager: NSObject {
    static let shared: GXUserManager = GXUserManager()

    /// 登录相关
    var token: String? = nil
    var isLogin: Bool {
        return self.token != nil
    }
    
    /// 全局筛选配置model
    lazy var filter: GXHomeFilterModel = {
        return GXHomeFilterModel()
    }()
    /// App版本更新model
    var appUpdateLatestData: GXAppUpdateLatestData?
    /// 系统参数
    var paramConsumerData: GXParamConsumerData?
    /// 周边设施
    var dictListAvailable: [GXDictListAvailableData] = []
    /// 周边设施
    var showDictListAvailable: [GXDictListAvailableData] = []
    
    override init() {}
}
