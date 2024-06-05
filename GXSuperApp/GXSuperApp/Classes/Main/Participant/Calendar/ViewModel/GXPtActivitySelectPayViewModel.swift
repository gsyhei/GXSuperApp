//
//  GXPtActivitySelectPayViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit

class GXPtActivitySelectPayViewModel: GXBaseViewModel {
    var infoData: GXActivityBaseInfoData?
    var signData: GXSignActivityData!

    /// 发起支付宝支付
    func requestPayAlipay(success:@escaping((String?) -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["orderSn"] = self.signData.orderSn
        params["paidType"] = 1
        let api = GXApi.normalApi(Api_CPay_Alipay, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if let data = model.data as? String {
                success(data)
            } else {
                success(nil)
            }
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 发起微信支付
    func requestPayWechat(success:@escaping((Dictionary<String, Any>?) -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["orderSn"] = self.signData.orderSn
        params["paidType"] = 2
        let api = GXApi.normalApi(Api_CPay_Wechat, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if let data = model.data as? Dictionary<String, Any> {
                success(data)
            } else {
                success(nil)
            }
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
}
