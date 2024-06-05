//
//  GXPublishFinancialViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit

class GXPublishFinancialViewModel: GXBaseViewModel {
    /// 活动data
    var activityData: GXActivityBaseInfoData!
    /// 分页
    var pageNum: Int = 1
    /// 财务小计data
    var infoData: GXActivityFinanceInfoData?
    /// 财务物料列表
    var list: [GXActivityfinancesListItem] = []

    /// 获取活动财务
    func requestGetActivityFinanceInfo(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityData.id
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_Activity_GetActivityFinanceInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityFinanceInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            self.infoData = model.data
            if let financesList = model.data?.activityFinances?.list {
                self.list.append(contentsOf: financesList)
            }
            self.pageNum = (self.list.count / PAGE_SIZE) + 1
            success((model.data?.activityFinances?.list.count ?? 0) < PAGE_SIZE)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 删除物料
    func requestDeleteFinance(financeId: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Finance_DeleteFinance, ["financeId": financeId], .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
