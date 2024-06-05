//
//  GXPublishEventListViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit

class GXPublishEventListViewModel: GXBaseViewModel {
    /// 活动data
    var activityData: GXActivityBaseInfoData!
    /// 数据内容
    var infoData: GXActivityEventInfoData?

    /// 获取活动事件
    func requestGetActivityEventInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityData.id

        let api = GXApi.normalApi(Api_Activity_GetActivityEventInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityEventInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.infoData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
