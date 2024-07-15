//
//  GXMineAccountManagerViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import PromiseKit

class GXMineAccountManagerViewModel: GXBaseViewModel {

    /// 退出登录
    func requestUserLogout() -> Promise<GXBaseModel> {
        return Promise { seal in
            let api = GXApi.normalApi(Api_auth_user_logout, [:], .post)
            GXNWProvider.login_request(api, type: GXBaseModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 注销账号
    func requestUserCancel() -> Promise<GXBaseModel> {
        return Promise { seal in
            let api = GXApi.normalApi(Api_auth_user_cancel, [:], .post)
            GXNWProvider.login_request(api, type: GXBaseModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
