//
//  GXMinePrOrderSearchViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit
import RxRelay

class GXMinePrOrderSearchViewModel: GXBaseViewModel {
    /// 搜索文本
    var searchWord = BehaviorRelay<String?>(value: nil)
    /// 分页
    var pageNum: Int = 1
    /// 订单列表
    var list: [GXListMyOrderItem] = []

    /// 根据手机号搜索订单
    func requestGetMyOrders(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["phone"] = self.searchWord.value
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_ActivityMy_MyOrdersByPhone, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityMyOrdersModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }

            guard let orders = model.data?.orders else {
                success(false); return
            }
            self.list.append(contentsOf: orders.list)
            self.pageNum = orders.pageNum + 1
            success(orders.pageNum >= orders.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
