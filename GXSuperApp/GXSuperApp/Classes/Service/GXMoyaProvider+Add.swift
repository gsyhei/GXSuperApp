//
//  GXMoyaProvider+Add.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/29.
//

import Foundation
import PromiseKit
import Moya

extension GXMoyaProvider {
    
    /// 获取用户信息
    func login_requestUserInfo() -> Promise<GXUserModel> {
        let api = GXApi.normalApi(Api_auth_user_profile, [:], .get)
        return Promise { seal in
            GXNWProvider.gx_request(api, type: GXUserModel.self, success: { model in
                GXUserManager.shared.user = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    func login_request<T: GXBaseModel>(_ target: GXApi, type: T.Type, success:@escaping GXSuccess<T>, failure:@escaping GXFailure) {
        if GXUserManager.shared.isLogin && GXUserManager.shared.user == nil && !GXUserManager.shared.isGetUser {
            GXUserManager.shared.isGetUser = true
            firstly {
                self.login_requestUserInfo()
            }.done { model in
                GXNWProvider.gx_request(target, type: type, success: success, failure: failure)
                GXUserManager.shared.isGetUser = false
            }.catch { error in
                failure(error as! CustomNSError)
                GXUserManager.shared.isGetUser = false
            }
        }
        else {
            GXNWProvider.gx_request(target, type: type, success: success, failure: failure)
        }
    }
    
}
