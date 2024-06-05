//
//  GXMoyaProvider+Add.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/11.
//

import Foundation
import Moya

extension GXMoyaProvider {

    @discardableResult
    func login_request<T: GXBaseModel>(_ target: GXApi, type: T.Type, success:@escaping GXSuccess<T>, failure:@escaping GXFailure) -> Cancellable {
        if GXUserManager.shared.isLogin && !GXUserManager.shared.isGetUser && GXUserManager.shared.user == nil {
            GXUserManager.shared.isGetUser = true
            let api = GXApi.normalApi(Api_User_GetUserInfo, [:], .get)
            return GXNWProvider.gx_request(api, type: GXUserInfoModel.self, success: { model in
                if let userInfo = model.data {
                    GXUserManager.updateUser(userInfo)
                }
                GXUserManager.shared.isGetUser = false
                GXNWProvider.gx_request(target, type: type, success: success, failure: failure)
            }) { error in
                GXUserManager.shared.isGetUser = false
                failure(error)
            }
        }
        else {
            return  GXNWProvider.gx_request(target, type: type, success: success, failure: failure)
        }
    }
}

