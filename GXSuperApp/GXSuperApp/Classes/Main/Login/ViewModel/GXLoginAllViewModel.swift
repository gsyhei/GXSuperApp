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
    
    // Google登录验证
    func requestGoogleLogin(token: String) -> Promise<GXLoginModel> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            params["idToken"] = token
            let api = GXApi.normal1Api(Api_auth_google_login, params, .post)
            GXNWProvider.gx_request(api, type: GXLoginModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    // Apple登录验证
    func requestAppleLogin(token: String) -> Promise<GXLoginModel> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            params["identifyToken"] = token
            let api = GXApi.normal1Api(Api_auth_apple_login, params, .post)
            GXNWProvider.gx_request(api, type: GXLoginModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }

    /// 绑定手机
    func requestBindPhone(tempToken: String) -> Promise<GXLoginModel> {
        var params: Dictionary<String, Any> = [:]
        params["nationCode"] = "86"
        params["phoneNumber"] = self.account.value
        params["smsCode"] = "123456"
        params["tempToken"] = tempToken
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
    
}
