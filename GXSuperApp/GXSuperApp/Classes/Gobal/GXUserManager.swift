//
//  GXUserManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/25.
//

import UIKit

/// 系统参数
let GX_PramConsumer = GXUserManager.shared.paramConsumerData
/// 周边设施
let GX_DictListAvailable = GXUserManager.shared.dictListAvailable
/// 主页显示的周边设施
let GX_ShowDictListAvailable = GXUserManager.shared.showDictListAvailable

class GXUserManager: NSObject {
    static let shared: GXUserManager = GXUserManager()

    enum SaveKey: String {
        /// 存储token的key
        case token = "gx_user_token"
    }
    
    /// 用户token
    lazy var token: String? = {
        return UserDefaults.standard.string(forKey: SaveKey.token.rawValue)
    }() {
        didSet {
            if let token = token {
                UserDefaults.standard.setValue(token, forKey: SaveKey.token.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: SaveKey.token.rawValue)
            }
            UserDefaults.standard.synchronize()
        }
    }
    /// 用户信息
    var isGetUser: Bool = false
    var user: GXUserData?
    /// 是否登录
    var isLogin: Bool {
        return self.token != nil
    }
    /// 是否vip
    var isVip: Bool {
        return self.user?.memberFlag == GX_YES
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
    /// 主页显示的周边设施
    var showDictListAvailable: [GXDictListAvailableData] = []
    /// 车辆列表
    var vehicleList: [GXVehicleConsumerListItem] = []
    
    override init() {}
}
