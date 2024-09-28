//
//  GXVipViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import PromiseKit
import XCGLogger

class GXVipViewModel: GXBaseViewModel {
    /// 轮询VIP
    var autouUpdateVipAction: GXActionBlockItem<Bool>?
    var autouUpdateVipIndex: Int = 0
    
    /// 系统配置
    func requestParamConsumer() -> Promise<GXParamConsumerData?> {
        let params: Dictionary<String, Any> = [:]
        let api = GXApi.normalApi(Api_param_consumer_detail, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXParamConsumerModel.self, success: { model in
                GXUserManager.shared.paramsData = model.data
                seal.fulfill(model.data)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    func autoUpdateVipRequest() {
        if GXUserManager.shared.isVip {
            self.autouUpdateVipAction?(true)
        }
        else {
            if self.autouUpdateVipIndex < 5 {
                self.autouUpdateVipIndex += 1
                self.perform(#selector(self.updateVipStateNext), with: nil, afterDelay: 3)
            }
            else {
                self.autouUpdateVipIndex = 0
                self.autouUpdateVipAction?(false)
            }
        }
    }
    
    @objc private func updateVipStateNext() {
        firstly {
            GXNWProvider.login_requestUserInfo()
        }.done { model in
            self.autoUpdateVipRequest()
        }.catch { error in
            XCGLogger.info(error.localizedDescription)
        }
    }
    
}
