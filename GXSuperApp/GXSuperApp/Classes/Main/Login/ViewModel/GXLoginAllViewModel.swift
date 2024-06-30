//
//  GXLoginAllViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/28.
//

import UIKit
import RxCocoa
import PromiseKit

class GXLoginAllViewModel: GXBaseViewModel {
    let account = BehaviorRelay<String?>(value: nil)
    let captcha = BehaviorRelay<String?>(value: nil)

    /// 获取短信验证码
    func requestSendCode() -> Promise<GXBaseModel> {
        var params: Dictionary<String, Any> = [:]
        params["nationCode"] = "86"
        params["phoneNumber"] = self.account.value
        let api = GXApi.normalApi(Api_auth_phone_code, params, .post)
        return Promise { seal in
            GXNWProvider.gx_request(api, type: GXBaseModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }

    /// 手机验证码登录
    func requestLogin() -> Promise<GXLoginModel> {
        var params: Dictionary<String, Any> = [:]
        params["nationCode"] = "86"
        params["phoneNumber"] = self.account.value
        params["smsCode"] = "123456"
        let api = GXApi.normalApi(Api_auth_phone_login, params, .post)
        return Promise { seal in
            GXNWProvider.gx_request(api, type: GXLoginModel.self, success: { model in
                GXUserManager.shared.token = model.data?.token
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }

    /// 绑定手机
    func requestBindPhone(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params.updateValue(self.account.value ?? "", forKey: "phone")
        params.updateValue(self.captcha.value ?? "", forKey: "smsCode")
        let api = GXApi.normalApi(Api_app_update_latest, params, .post)
        GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            //GXUserManager.shared.user?.phone = self.account.value ?? ""
            success()
        }, failure: failure)
    }
    
}
