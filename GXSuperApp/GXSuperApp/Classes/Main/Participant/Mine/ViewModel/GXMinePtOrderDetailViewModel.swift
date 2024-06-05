//
//  GXMinePtOrderDetailViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/10.
//

import UIKit

class GXMinePtOrderDetailViewModel: GXBaseViewModel {
    var orderSn: String?
    var data: GXMinePtOrderDetailData?

    /// 订单详情
    func requestGetSelectByOrderSn(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["orderSn"] = self.orderSn
        let api = GXApi.normalApi(Api_COrder_SelectByOrderSn, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXMinePtOrderDetailModel.self, success: {[weak self] model in
            self?.data = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
