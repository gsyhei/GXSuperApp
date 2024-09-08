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
    var list: [GXCodesPopoverListMdel] = []
    var codeModel: GXCodesPopoverListMdel?
    
    /// 系统配置
    func requestParamConsumer() -> Promise<GXParamConsumerData?> {
        let params: Dictionary<String, Any> = [:]
        let api = GXApi.normalApi(Api_param_consumer_detail, params, .get)
        return Promise { seal in
            if let paramsData = GXUserManager.shared.paramsData {
                self.updateCodesList()
                seal.fulfill(paramsData); return
            }
            GXNWProvider.gx_request(api, type: GXParamConsumerModel.self, success: { model in
                GXUserManager.shared.paramsData = model.data
                self.updateCodesList()
                seal.fulfill(model.data)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 获取短信验证码
    func requestSendCode() -> Promise<GXBaseModel> {
        var params: Dictionary<String, Any> = [:]
        params["nationCode"] = self.codeModel?.code
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
        params["nationCode"] = self.codeModel?.code
        params["phoneNumber"] = self.account.value
        params["smsCode"] = self.captcha.value
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
            let api = GXApi.normalOtherApi(Api_auth_google_login, params, .post)
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
            let api = GXApi.normalOtherApi(Api_auth_apple_login, params, .post)
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
        params["nationCode"] = self.codeModel?.code
        params["phoneNumber"] = self.account.value
        params["smsCode"] = self.captcha.value
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

extension GXLoginAllViewModel {
    func updateCodesList() {
        self.list.removeAll()
        let nationCodes = GXUserManager.shared.paramsData?.nationCodes ?? []
        for code in nationCodes {
            self.list.append(GXCodesPopoverListMdel(title: "+" + code, code: code))
        }
        self.codeModel = self.list.first
    }
}
