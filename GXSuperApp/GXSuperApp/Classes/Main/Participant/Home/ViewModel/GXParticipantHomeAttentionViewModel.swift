//
//  GXParticipantHomeAttentionViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/20.
//

import UIKit

class GXParticipantHomeAttentionViewModel: GXBaseViewModel {
    /// 是否为感兴趣的人（未关注任何人）
    lazy var isFollow: Bool = {
        return (GXUserManager.shared.user?.followNum ?? 0 == 0)
    }()
    /// 可能感兴趣的人
    var userList: [GXListMyFansItem] = []
    /// 关注的人发布的活动
    var activityList: [GXActivityBaseInfoData] = []
    /// 页码 - 关注的人发布的活动
    var pageNum: Int = 1

    /// 可能感兴趣的人
    func requestGetListMayBeInterested(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CUser_ListMayBeInterested, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXHomeListMayBeInterestedModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.userList = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 关注的人发布的活动
    func requestGeFollowActivity(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
            if refresh {
                self.pageNum = 1
            }
            var params: Dictionary<String, Any> = [:]
            params["pageNum"] = self.pageNum
            params["pageSize"] = PAGE_SIZE
        let api = GXApi.normalApi(Api_CUser_FollowActivity, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXHomeFollowActivityModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            guard let data = model.data else {
                success(false); return
            }
            if refresh { self.activityList.removeAll() }
            self.activityList.append(contentsOf: data.list)
            self.pageNum = data.pageNum + 1
            success(data.pageNum >= data.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 关注-取消关注
    func requestFollowUser(index: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let item = self.userList[index]
        var params: Dictionary<String, Any> = [:]
        params["userId"] = item.id
        let api = GXApi.normalApi(Api_CUser_FollowUser, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            item.followEachOther = !item.followEachOther
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 一键关注
    func requestFollowUsers(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var userIds: [String] = []
        for user in self.userList {
            userIds.append(user.id)
        }
        var params: Dictionary<String, Any> = [:]
        params["userIds"] = userIds
        let api = GXApi.normalApi(Api_CUser_FollowUsers, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            for user in self.userList {
                user.followEachOther = true
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
