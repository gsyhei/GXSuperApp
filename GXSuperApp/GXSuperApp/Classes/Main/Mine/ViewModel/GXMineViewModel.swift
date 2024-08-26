//
//  GXMineViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import PromiseKit

class GXMineViewModel: GXBaseViewModel {
    /// 动态配置cell
    var cellIndexs: [Int] = [0, 1, 2, 3]
    /// 钱包余额
    var balanceData: GXWalletConsumerBalanceData?
    /// 钱包余额
    var orderTotal: Int = 0
    /// 按钮配置
    lazy var cell2Models: [GXMineCell2ItemModel] = {
        return [
            GXMineCell2ItemModel(imageName: "my_card_ic_favorites", title: "Favorites"),
            GXMineCell2ItemModel(imageName: "my_card_ic_vehicles", title: "My Vehicles"),
            GXMineCell2ItemModel(imageName: "my_card_ic_agreements", title: "Agreements"),
            GXMineCell2ItemModel(imageName: "my_card_ic_card", title: "Cards"),
            GXMineCell2ItemModel(imageName: "my_card_ic_faq", title: "FAQ"),
            GXMineCell2ItemModel(imageName: "my_card_ic_contact", title: "Contact Us"),
            GXMineCell2ItemModel(imageName: "my_card_ic_settings", title: "Settings")
        ]
    }()
    
    /// 更新配置
    func updateConfigCellIndexs() {
        if GXUserManager.shared.isVip {
            self.cellIndexs = [0, 1, 2, 3]
        }
        else {
            self.cellIndexs = [0, 3, 1, 2]
        }
    }
    
    /// 系统配置
    func requestParamConsumer() -> Promise<GXParamConsumerData?> {
        return Promise { seal in
            if let paramsData = GXUserManager.shared.paramsData {
                seal.fulfill(paramsData); return
            }
            let api = GXApi.normalApi(Api_param_consumer_detail, [:], .get)
            GXNWProvider.login_request(api, type: GXParamConsumerModel.self, success: { model in
                GXUserManager.shared.paramsData = model.data
                seal.fulfill(model.data)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 钱包余额
    func requestWalletConsumerBalance() -> Promise<GXWalletConsumerBalanceModel?> {
        let api = GXApi.normalApi(Api_wallet_consumer_balance, [:], .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXWalletConsumerBalanceModel.self, success: { model in
                self.balanceData = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 订单总数
    func requestOrderConsumerTotal() -> Promise<GXBaseDataModel?> {
        let api = GXApi.normalApi(Api_order_consumer_total, [:], .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
                if let dataJson = model.data as? [String: Any], let total = dataJson["total"] as? Int {
                    self.orderTotal = total
                }
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }    
    
    /// 修改资料->头像
    func requestAuthUserProfileEdit(photo: String) -> Promise<String> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            params["photo"] = photo
            let api = GXApi.normalApi(Api_auth_user_profile_edit, params, .post)
            GXNWProvider.login_request(api, type: GXBaseModel.self, success: { model in
                seal.fulfill(photo)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
