//
//  GXConversationUsersSearchViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/22.
//

import UIKit
import RxRelay

class GXConversationUsersSearchViewModel: GXBaseViewModel {
    /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
    var messageType: Int = 0
    /// 活动名称搜素
    var searchWord = BehaviorRelay<String?>(value: nil)
    /// 分页
    var pageNum: Int = 1
    /// 消息
    var list: [GXListUserMessagesItem] = []

    /// 用户消息
    func requestGetListUserMessages(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["messageType"] = self.messageType
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE
        params["activityName"] = self.searchWord.value
        let api = GXApi.normalApi(Api_Message_ListUserMessages, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXListUserMessagesModel.self, success: {[weak self] model in
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

}
