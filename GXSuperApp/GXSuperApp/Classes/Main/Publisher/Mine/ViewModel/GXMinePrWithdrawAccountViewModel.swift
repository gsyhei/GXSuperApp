//
//  GXMinePrWithdrawAccountViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/15.
//

import UIKit
import RxRelay

class GXMinePrWithdrawAccountViewModel: GXBaseViewModel {
    /// 获取提现账号
    var withdrawAccountData: GXWithdrawAccountData?
    /// 支付宝账号
    var aliAcccount = BehaviorRelay<String?>(value: nil)
    /// 真实姓名
    var realName = BehaviorRelay<String?>(value: nil)
    /// 验证码
    var captcha = BehaviorRelay<String?>(value: nil)

    /// 获取提现账号
    func requestGetWithdrawAccount(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_WithdrawAccount_GetWithdrawAccount, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXWithdrawAccountModel.self, success: {[weak self] model in
            self?.withdrawAccountData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
    /// 发送验证码
    func requestGetSmsCode(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_WithdrawAccount_GetSmsCode, [:], .post)
        let cancellable = GXNWProvider.login_request(api, type: GXWithdrawAccountModel.self, success: {model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 设置提现账号
    func requestSetWithdrawAccount(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        //        {
        //        "alipayAccount": "",
        //        "realName": "",
        //        "smsCode": ""
        //        }
        var params: Dictionary<String, Any> = [:]
        params["alipayAccount"] = self.aliAcccount.value
        params["realName"] = self.realName.value
        params["smsCode"] = self.captcha.value
        let api = GXApi.normalApi(Api_WithdrawAccount_SetWithdrawAccount, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
