//
//  GXParticipantHomeSearchViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import RxRelay

class GXParticipantHomeSearchViewModel: GXBaseViewModel {
    /// 搜索文本
    var searchWord = BehaviorRelay<String?>(value: nil)
    /// 分页
    var pageNum: Int = 1
    /// 搜索内容
    var list: [GXCalendarActivityItem] = []

    /// 搜索活动
    func requestGetSearchActivity(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["searchWord"] = self.searchWord.value
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_CActivity_SearchActivity, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXCalendarActivityModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            guard let data = model.data else {
                success(false); return
            }
            if refresh { self.list.removeAll() }
            self.list.append(contentsOf: data.list)
            self.pageNum = data.pageNum + 1
            success(data.pageNum >= data.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
