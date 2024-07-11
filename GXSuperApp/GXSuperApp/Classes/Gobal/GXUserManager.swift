//
//  GXUserManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/25.
//

import UIKit

class GXUserManager: NSObject {
    static let shared: GXUserManager = GXUserManager()

    enum SaveKey: String {
        /// 存储token的key
        case token = "gx_user_token"
    }
    
    // MARK: - 用户相关
    
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
    /// 车辆列表
    var vehicleList: [GXVehicleConsumerListItem] = []
    /// 选择车辆
    var selectedVehicle: GXVehicleConsumerListItem?
    /// 进行中的订单
    var orderDoing: GXOrderConsumerDoingData?
    
    // MARK: - 全局相关
    
    /// 筛选配置model
    lazy var filter: GXHomeFilterModel = {
        return GXHomeFilterModel()
    }()
    /// App版本更新model
    var appUpdateData: GXAppUpdateLatestData?
    /// 系统参数
    var paramsData: GXParamConsumerData?
    /// 周边设施
    var availableList: [GXDictListAvailableData] = []
    /// 主页显示的周边设施
    var showAvailableList: [GXDictListAvailableData] = []
    /// 申诉类型
    var appealTypeList: [GXDictListAvailableData] = []
    
    /// 登出
    class func logout() {
//        guard GXUserManager.shared.isLogin else { return }
        GXUserManager.shared.token = nil
        GXUserManager.shared.vehicleList = []
        GXUserManager.shared.selectedVehicle = nil
        GXUserManager.shared.orderDoing = nil
        
        /// 清理完数据再通知
        GXAppDelegate?.logout()
    }
    
}
