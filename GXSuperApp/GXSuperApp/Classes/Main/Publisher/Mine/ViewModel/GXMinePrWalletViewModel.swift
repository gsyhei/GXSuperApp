//
//  GXMinePrWalletViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/12.
//

import UIKit

class GXMinePrWalletViewModel: GXBaseViewModel {
    /// 分页
    var pageNum: Int = 1
    /// 我的钱包记录列表
    var list: [GXFundjoursItem] = []
    var data: GXGetMyWalletData?
    
    /// 请求我发布的活动
    func requestGetMyWallet(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_User_getMyWallet, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetMyWalletModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }

            self.data = model.data
            guard let fundJours = model.data?.fundJours else {
                success(false); return
            }
            self.list.append(contentsOf: fundJours.list)
            self.pageNum = fundJours.pageNum + 1
            success(fundJours.pageNum >= fundJours.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
