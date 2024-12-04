//
//  GXMinePayManagerViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/15.
//

import UIKit
import PromiseKit

class GXMinePayManagerViewModel: GXBaseViewModel {
    /// 钱包余额
    var balanceData: GXWalletConsumerBalanceData?
    /// 支付列表
    var model: GXStripePaymentListModel?
    /// 当前选择支付卡
    var selectedItem: GXStripePaymentListDataItem?
    
    /// 支付账号列表
    func requestStripePaymentList() -> Promise<GXStripePaymentListModel> {
        return Promise { seal in
            let api = GXApi.normalApi(Api_stripe_consumer_payment_method_list, [:], .get)
            GXNWProvider.login_request(api, type: GXStripePaymentListModel.self, success: { model in
                self.model = model
                for item in model.data {
                    if item.default {
                        self.selectedItem = item; break
                    }
                }
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 钱包余额
    func requestWalletConsumerBalance() -> Promise<GXWalletConsumerBalanceModel?> {
        let api = GXApi.normalApi(Api_wallet_consumer_balance, [:], .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXWalletConsumerBalanceModel.self, success: { model in
                self.balanceData = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 移除支付账号
    func requestStripePaymentDetach(index: Int) -> Promise<GXBaseDataModel> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            params["paymentMethodId"] = self.model?.data[index].paymentMethodId
            let api = GXApi.normalApi(Api_stripe_consumer_payment_method_detach, params, .post)
            GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// Stripe-设置未来支付
    func requestStripeConsumerSetupIntent() -> Promise<GXStripePaymentData> {
        return Promise { seal in
            let api = GXApi.normalApi(Api_stripe_consumer_setup_intent, [:], .post)
            GXNWProvider.login_request(api, type: GXStripePaymentModel.self, success: { model in
                seal.fulfill(model.data ?? GXStripePaymentData())
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 设置付款方式
    func requestStripePaymentMethodSet() -> Promise<GXBaseDataModel> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            if let item = self.selectedItem {
                params["paymentMethod"] = "SETUP_INTENT"
                params["paymentMethodId"] = item.paymentMethodId
            }
            else {
                params["paymentMethod"] = "BALANCE"
            }
            let api = GXApi.normalApi(Api_wallet_consumer_payment_method_set, params, .post)
            GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
