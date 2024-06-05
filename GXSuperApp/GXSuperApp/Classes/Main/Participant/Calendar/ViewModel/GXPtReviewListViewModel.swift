//
//  GXPtReviewListViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/31.
//

import UIKit

class GXPtReviewListViewModel: GXBaseViewModel {
    /// 活动data
    var activityId: Int = 0
    /// 分页
    var pageNum: Int = 1
    /// 回顾列表
    var list: [GXActivityreviewsListItem] = []

    /// 获取活动回顾
    func requestGetActivityReviewInfo(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        params["reviewStatus"] = 1
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE
        let api = GXApi.normalApi(Api_CActivity_GetActivityReviewInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetActivityReviewInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            guard let activityReviews = model.data?.activityReviews else {
                success(false); return
            }
            self.list.append(contentsOf: activityReviews.list)
            self.pageNum = activityReviews.pageNum + 1
            success(activityReviews.pageNum >= activityReviews.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
