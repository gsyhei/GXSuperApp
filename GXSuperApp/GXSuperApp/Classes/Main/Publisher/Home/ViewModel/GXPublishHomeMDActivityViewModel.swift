//
//  GXPublishHomeMPActivityViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit

class GXPublishHomeMDActivityViewModel: GXBaseViewModel {
    // MARK: - 入参

    /// 分页
    var pageNum: Int = 1
    
    // MARK: - request

    /// 活动列表
    var list: [GXActivityBaseInfoData] = []

    /// 请求我的草稿
    func requestGetListMyActivity(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_Activity_ListMyDraft, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXMyActivityModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            self.list.append(contentsOf: model.data)
            self.pageNum = (self.list.count / PAGE_SIZE) + 1
            success(model.data.count < PAGE_SIZE)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
    /// 删除活动
    func requestActivityDelete(index: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let infoData = self.list[index]
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = infoData.id
        let api = GXApi.normalApi(Api_Activity_Delete, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            self.list.remove(at: index)
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
