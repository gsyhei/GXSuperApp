//
//  GXConversationUsersListViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit

class GXConversationUsersListViewModel: GXBaseViewModel {
    /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
    var messageType: Int = 0
    /// 活动id
    var activityId: Int?
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
        if let letActivityId = self.activityId {
            params["activityId"] = letActivityId
        }
        let api = GXApi.normalApi(Api_Message_ListUserMessages, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXListUserMessagesModel.self, success: {[weak self] model in
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

    /// 通知是否显示小红点
    func postNotificationRedPoint() {
        guard let data = GXUserManager.shared.tabRedPointData else { return }
        if self.messageType == 1 || self.messageType == 2 {
            data.consultationRedPoint = self.isShowRedPoint()
        }
        else if self.messageType == 3 || self.messageType == 4 {
            data.signRedPoint = self.isShowRedPoint()
        }
        else if self.messageType == 5 {
            data.workRedPoint = self.isShowRedPoint()
        }
        NotificationCenter.default.post(name: GX_NotifName_UpdateTabRedPoint, object: nil)
    }
    
    /// 置顶-取消置顶回顾
    func requestMessageSetTop(chatId: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["chatId"] = chatId
        let api = GXApi.normalApi(Api_Message_SetTop, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 删除会话
    func requestMessageDelete(chatId: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["chatId"] = chatId
        let api = GXApi.normalApi(Api_Message_DeleteChat, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}

private extension GXConversationUsersListViewModel {
    /// 获取是否显示小红点
    func isShowRedPoint() -> Bool {
        for item in self.list {
            if item.redPoint {
                return true
            }
        }
        return false
    }
}
