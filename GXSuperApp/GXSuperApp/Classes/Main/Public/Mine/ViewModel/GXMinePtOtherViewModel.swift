//
//  GXMinePtOtherViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/8.
//

import UIKit

class GXMinePtOtherViewModel: GXBaseViewModel {
    /// 用户ID
    var userId: String = ""
    /// 分页
    var pageNum: Int = 1

    // MARK: - request
    var data: GXUserHomepageData?
    /// 票列表
    var list: [GXCalendarActivityItem] = []

    /// 获取用户主页
    func requestGetAllUserHomepage(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if GXUserManager.shared.roleType == .publisher {
            self.requestGetUserHomepager(refresh: refresh, success: success, failure: failure)
        }
        else {
            self.requestGetCUserHomepage(refresh: refresh, success: success, failure: failure)
        }
    }

    /// 获取用户主页- 参与端
    func requestGetCUserHomepage(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["userId"] = self.userId
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_CUser_GetUserHomepage, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXUserHomepageModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            guard let activityPage = model.data?.activityCommonPage else {
                success(false); return
            }
            self.data = model.data
            self.list.append(contentsOf: activityPage.list)
            self.pageNum = activityPage.pageNum + 1
            success(activityPage.pageNum >= activityPage.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 获取用户主页- 发布端
    func requestGetUserHomepager(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["userId"] = self.userId
        params["pageNum"] = self.pageNum
        params["pageSize"] = 0

        let api = GXApi.normalApi(Api_Activity_GetUserHomepage, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXUserHomepageModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            guard let activityPage = model.data?.activityCommonPage else {
                success(false); return
            }
            self.data = model.data
            self.list.append(contentsOf: activityPage.list)
            self.pageNum = activityPage.pageNum + 1
            success(true)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 关注-取消关注
    func requestFollowUser(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let fansFlag = self.data?.fansFlag == 1 ? 0 : 1
        var params: Dictionary<String, Any> = [:]
        params["userId"] = self.userId
        let api = GXApi.normalApi(Api_CUser_FollowUser, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.data?.fansFlag = fansFlag
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
