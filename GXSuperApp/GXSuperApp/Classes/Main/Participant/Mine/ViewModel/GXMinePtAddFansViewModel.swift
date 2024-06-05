//
//  GXMinePtAddFansViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit

class GXMinePtAddFansViewModel: GXBaseViewModel {
    /// 0-我的粉丝  1-我的关注
    var selectIndex: Int = 0
    /// 分页
    var pageNum: Int = 1
    /// 粉丝/关注
    var list: [GXListMyFansItem] = []

    /// 我的粉丝/关注
    func requestGetList(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if self.selectIndex == 0 {
            self.requestGetListMyFans(refresh: refresh, success: success, failure: failure)
        }
        else {
            self.requestGetListMyFollows(refresh: refresh, success: success, failure: failure)
        }
    }

    /// 我的粉丝
    func requestGetListMyFans(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_CUser_ListMyFans, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXListMyFansModel.self, success: {[weak self] model in
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

    /// 我的关注
    func requestGetListMyFollows(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_CUser_ListMyFollows, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXListMyFansModel.self, success: {[weak self] model in
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

    /// 关注-取消关注
    func requestFollowUser(index: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let item = self.list[index]
        var params: Dictionary<String, Any> = [:]
        params["userId"] = item.id
        let api = GXApi.normalApi(Api_CUser_FollowUser, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if self.selectIndex == 0 {
                item.followEachOther = !item.followEachOther
            } else {
                item.isDelete = !item.isDelete
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
