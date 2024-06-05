//
//  GXMinePrOrderViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit

class GXMinePrOrderViewModel: GXBaseViewModel {
    /// 周期 1-本月 2-三个月内 3-半年内 4-一年内 5-三年内
    var cycleType: Int?
    /// 活动对象
    var activityData: GXActivityBaseInfoData?
    /// 分页
    var pageNum: Int = 1
    /// 订单列表
    var list: [GXListMyOrderItem] = []

    // MARK: - 活动赛选菜单

    /// 分页
    var menuPageNum: Int = 1
    var menuNoMore: Bool = false
    /// 活动列表
    var menuList: [GXActivityBaseInfoData] = []

    /// 请求我发布的活动
    func requestGetListMyActivity(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.menuPageNum = 1
            self.menuNoMore = false
        }
        var params: Dictionary<String, Any> = [:]
        params["shelfStatus"] = 1
        params["pageNum"] = self.menuPageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_Activity_ListMyActivity, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXMyActivityModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.menuList.removeAll() }
            self.menuList.append(contentsOf: model.data)
            self.menuPageNum = (self.menuList.count / PAGE_SIZE) + 1
            self.menuNoMore = model.data.count < PAGE_SIZE
            success(self.menuNoMore)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 我的订单
    func requestGetMyOrders(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        if let activityId = self.activityData?.id {
            params["activityId"] = activityId
        }
        if let type = self.cycleType {
            params["cycleType"] = type
        }
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_ActivityMy_MyOrders, params, .get)
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
