//
//  GXConversationSystemListViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit

class GXConversationSystemListViewModel: GXBaseViewModel {
    /// 分页
    var pageNum: Int = 1
    /// 消息
    var list: [GXListSystemMessagesItem] = []

    /// 用户消息
    func requestGetListSystemMessages(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_Message_ListSystemMessages, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXListSystemMessagesModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            guard let data = model.data else {
                success(false); return
            }
            self.list.append(contentsOf: data.list)
            self.postNotificationRedPoint()
            self.pageNum = data.pageNum + 1
            success(data.pageNum >= data.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 设置已读
    func requestSetReadFlag(index: Int, success: (() -> Void)? = nil, failure: GXFailure? = nil) {
        let item = self.list[index]
        var params: Dictionary<String, Any> = [:]
        params["ids"] = [item.id]
        let api = GXApi.normalApi(Api_Message_SetReadFlag, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            item.readFlag = true
            success?()
        }) { error in
            failure?(error)
        }
        self.gx_addCancellable(cancellable)
    }

    /// 获取是否显示小红点
    func isShowRedPoint() -> Bool {
        for item in self.list {
            if !item.readFlag {
                return true
            }
        }
        return false
    }

    /// 通知是否显示小红点
    func postNotificationRedPoint() {
        guard let data = GXUserManager.shared.tabRedPointData else { return }
        data.systemMessageRedPoint = self.isShowRedPoint()
        NotificationCenter.default.post(name: GX_NotifName_UpdateTabRedPoint, object: nil)
    }

}
