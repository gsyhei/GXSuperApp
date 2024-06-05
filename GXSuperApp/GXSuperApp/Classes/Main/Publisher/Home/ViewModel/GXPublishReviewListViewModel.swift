//
//  GXPublishReviewListViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/21.
//

import UIKit

class GXPublishReviewListViewModel: GXBaseViewModel {
    /// 活动Id
    var activityId: Int = 0
    /// 回顾状态 0-待审核 1-审核通过/已启用 2-审核未通过/已禁用
    var reviewStatus: Int?
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
        params["reviewStatus"] = self.reviewStatus
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_Activity_GetActivityReviewInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetActivityReviewInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            if let reviewList = model.data?.activityReviews?.list {
                self.list.append(contentsOf: reviewList)
            }
            self.pageNum = (self.list.count / PAGE_SIZE) + 1
            success((model.data?.activityReviews?.list.count ?? 0) < PAGE_SIZE)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 禁用-启用回顾 (reviewStatus  回顾状态 1-审核通过/上架/启用 2-审核未通过/禁用)
    func requestModifyReviewStatus(reviewId: Int, reviewStatus: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["reviewId"] = reviewId
        params["reviewStatus"] = reviewStatus
        let api = GXApi.normalApi(Api_Review_ModifyReviewStatus, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 置顶-取消置顶回顾
    func requestModifyReviewSetTop(reviewId: Int, setTop: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["reviewId"] = reviewId
        params["setTop"] = setTop
        let api = GXApi.normalApi(Api_Review_SetTop, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
