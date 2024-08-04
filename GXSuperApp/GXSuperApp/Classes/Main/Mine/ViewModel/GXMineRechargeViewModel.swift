//
//  GXMineRechargeViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/4.
//

import UIKit
import PromiseKit

class GXMineRechargeViewModel: GXBaseViewModel {

    
    /// Stripe支付
    func requestStripeConsumerPayment(amount: Int) -> Promise<GXStripePaymentData> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            params["type"] = "RECHARGE"
            params["amount"] = amount
            let api = GXApi.normalApi(Api_stripe_consumer_payment, params, .post)
            GXNWProvider.login_request(api, type: GXStripePaymentModel.self, success: { model in
                seal.fulfill(model.data ?? GXStripePaymentData())
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
