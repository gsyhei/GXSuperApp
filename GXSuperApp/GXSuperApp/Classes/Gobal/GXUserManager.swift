//
//  GXUserManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/25.
//

import UIKit

let GX_PramConsumer = GXUserManager.shared.paramConsumerData
let GX_DictListAvailable = GXUserManager.shared.dictListAvailable
let GX_ShowDictListAvailable = GXUserManager.shared.showDictListAvailable

class GXUserManager: NSObject {
    static let shared: GXUserManager = GXUserManager()

    var token: String? = nil
    /// 是否登录
    var isLogin: Bool {
        return false
    }
    /// 是否vip
    var isVip: Bool {
        return false
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
