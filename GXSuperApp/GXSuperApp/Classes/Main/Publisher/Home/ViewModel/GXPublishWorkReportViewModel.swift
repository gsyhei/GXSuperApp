//
//  GXPublishWorkReportViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit

class GXPublishWorkReportViewModel: GXBaseViewModel {
    /// 活动id
    var activityId: Int = 0
    /// 分页
    var pageNum: Int = 1
    /// 汇报列表
    var list: [GXActivityreportsItem] = []

    /// 获取工作汇报
    func requestGetActivityReportInfo(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_Activity_GetActivityReportInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityReportInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            if let reviewList = model.data?.activityReports?.list {
                self.list.append(contentsOf: reviewList)
            }
            self.pageNum = (self.list.count / PAGE_SIZE) + 1
            success((model.data?.activityReports?.list.count ?? 0) < PAGE_SIZE)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
