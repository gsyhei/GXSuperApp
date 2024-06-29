//
//  GXLoginAllViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/28.
//

import UIKit
import RxCocoa

class GXLoginAllViewModel: GXBaseViewModel {
    let account = BehaviorRelay<String?>(value: nil)
    let captcha = BehaviorRelay<String?>(value: nil)

    /// 获取短信验证码
    func requestSendCode(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_app_update_latest, ["phone": self.account.value ?? ""], .post)
        let cancellable = GXNWProvider.gx_request(api, type: GXBaseModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestLogin(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params.updateValue(self.account.value ?? "", forKey: "account")
        params.updateValue(self.captcha.value ?? "", forKey: "smsCode")
        let api = GXApi.normalApi(Api_app_update_latest, params, .post)
        let cancellable = GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            if let token = model.data as? String {
                //GXUserManager.updateToken(token)
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestBindPhone(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params.updateValue(self.account.value ?? "", forKey: "phone")
        params.updateValue(self.captcha.value ?? "", forKey: "smsCode")
        let api = GXApi.normalApi(Api_app_update_latest, params, .post)
        let cancellable = GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            //GXUserManager.shared.user?.phone = self.account.value ?? ""
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
