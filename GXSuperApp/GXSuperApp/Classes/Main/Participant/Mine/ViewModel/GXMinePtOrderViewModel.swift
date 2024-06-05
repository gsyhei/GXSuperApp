//
//  GXMinePtOrderViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit

class GXMinePtOrderViewModel: GXBaseViewModel {
    /// 分页
    var pageNum: Int = 1
    /// 粉丝/关注
    var list: [GXListMyOrderItem] = []

    /// 我的订单
    func requestGetListMyFavorite(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_CUser_ListMyOrder, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXListMyOrderModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }

            guard let data = model.data else {
                success(false); return
            }
            self.list.append(contentsOf: data.list)
            self.pageNum = data.pageNum + 1
            success(data.pageNum >= data.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
