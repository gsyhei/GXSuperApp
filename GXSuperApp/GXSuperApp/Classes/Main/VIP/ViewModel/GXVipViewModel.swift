//
//  GXVipViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import PromiseKit

class GXVipViewModel: GXBaseViewModel {

    /// 系统配置
    func requestParamConsumer() -> Promise<GXParamConsumerData?> {
        let params: Dictionary<String, Any> = [:]
        let api = GXApi.normalApi(Api_param_consumer_detail, params, .get)
        return Promise { seal in
            if let paramsData = GXUserManager.shared.paramsData {
                seal.fulfill(paramsData); return
            }
            GXNWProvider.login_request(api, type: GXParamConsumerModel.self, success: { model in
                GXUserManager.shared.paramsData = model.data
                seal.fulfill(model.data)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
