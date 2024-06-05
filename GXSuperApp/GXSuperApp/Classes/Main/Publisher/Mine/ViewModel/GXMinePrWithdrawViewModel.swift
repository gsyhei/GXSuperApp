//
//  GXMinePrWithdrawViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/15.
//

import UIKit

class GXMinePrWithdrawViewModel: GXBaseViewModel {
    var withdrawPrice: Float = 0
    /// 钱包数据
    var walletData: GXGetMyWalletData!
    /// 获取财务设置信息
    var financeSettingData: GXGetFinanceSettingData?
    /// 获取提现账号
    var withdrawAccountData: GXWithdrawAccountData?

    /// 获取财务设置信息
    func requestGetFinanceSetting(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Withdraw_GetFinanceSetting, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetFinanceSettingModel.self, success: {[weak self] model in
            self?.financeSettingData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 获取提现账号
    func requestGetWithdrawAccount(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_WithdrawAccount_GetWithdrawAccount, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXWithdrawAccountModel.self, success: {[weak self] model in
            self?.withdrawAccountData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 发起提现
    func requestCreateWithdraw(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["entrustBalance"] = self.withdrawPrice
        let api = GXApi.normalApi(Api_Withdraw_CreateWithdraw, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
}
