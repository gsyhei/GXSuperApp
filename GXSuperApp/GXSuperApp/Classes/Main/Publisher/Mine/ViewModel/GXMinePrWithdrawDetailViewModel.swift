//
//  GXMinePrWithdrawDetailViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit

class GXMinePrWithdrawDetailViewModel: GXBaseViewModel {
    var item: GXFundjoursItem!
    var data: GXGetWithdrawDetailData?

    /// 查看历史提现详情
    func requestGetWithdrawDetail(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["withdrawId"] = item.withdrawId
        let api = GXApi.normalApi(Api_User_GetWithdrawDetail, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetWithdrawDetailModel.self, success: {model in
            self.data = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
}
