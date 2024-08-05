//
//  GXMineWithdrawViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import PromiseKit

class GXMineWithdrawViewModel: GXBaseViewModel {
    /// 钱包余额
    var balanceData: GXWalletConsumerBalanceData?
    
    /// 钱包余额
    func requestWalletConsumerBalance() -> Promise<GXWalletConsumerBalanceModel?> {
        return Promise { seal in
            let api = GXApi.normalApi(Api_wallet_consumer_balance, [:], .get)
            GXNWProvider.login_request(api, type: GXWalletConsumerBalanceModel.self, success: { model in
                self.balanceData = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 提现
    func requestWithdrawConsumerSubmit(amount: Float) -> Promise<GXWithdrawSubmitModel> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            params["amount"] = amount
            let api = GXApi.normalApi(Api_withdraw_consumer_submit, params, .post)
            GXNWProvider.login_request(api, type: GXWithdrawSubmitModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
