//
//  GXChatViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/21.
//

import UIKit
import HXPhotoPicker

class GXChatViewModel: GXBaseViewModel {
    /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
    var messageType: Int = 0
    /// 聊天对象ID（可能是咨询ID/活动ID）
    var chatId: Int = 0
    /// 活动id
    var activityId: Int = 0
    /// 消息数据
    var data: GXListUserMessagesItem?
    /// 成员
    var userList: [GXActivityUser] = []
    /// 工作人员ID
    var staffsUserIds: Set<Int> = []
    /// 活动基础信息(PUSH跳转无活动名称的时候查询)
    var infoData: GXActivityBaseInfoData?

    /// 参与端获取活动咨询
    func requestGetChatList(success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
        var apiMethod: String = ""
        switch self.messageType {
        case 1:
            params["activityId"] = self.activityId
            apiMethod = Api_CAChat_GetActivityChatInfo
        case 2:
            params["chatId"] = self.chatId
            apiMethod = Api_PAChat_GetActivityChatInfo
        case 3:
            params["activityId"] = self.activityId
            apiMethod = Api_CAChat_GetActivitySignChatInfo
        case 4:
            params["activityId"] = self.activityId
            apiMethod = Api_PAChat_GetActivitySignChatInfo
        case 5:
            params["activityId"] = self.activityId
            apiMethod = Api_PAChat_GetActivityWorkChatInfo
        default: break
        }
        let api = GXApi.normalApi(apiMethod, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXChatConsultModel.self, success: {[weak self] model in
            var isUpdate = false
            if let data = model.data {
                if data.children.count > 0 {
                    isUpdate = data.children.count > (self?.data?.children.count ?? 0)
                }
                else {
                    isUpdate = data.children.count == (self?.data?.children.count ?? 0)
                }
                self?.data = model.data
            }
            success(isUpdate)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 参与端发布活动咨询
    func requestChatSendUpload(text: String, photoAssets: [PhotoAsset], success:@escaping(() -> Void), failure:@escaping GXFailure) {
        GXApiUtil.requestUploadList(images: photoAssets, success: {[weak self] in
            self?.requestChatSend(text: text, photoAssets: photoAssets, success: success, failure: failure)
        }, failure: failure)
    }
    
    /// 获取活动报名群人员
    func requestActivityUsers(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        self.userList.removeAll()
        self.staffsUserIds.removeAll()

        let group = DispatchGroup()
        group.enter()
        self.requestGetUserLists(type: 2, success: {
            group.leave()
        }, failure: { error in
            failure(error)
            group.leave()
        })
        if self.messageType == 3 || self.messageType == 4 {
            group.enter()
            self.requestGetUserLists(type: 1, success: {
                group.leave()
            }, failure: { error in
                failure(error)
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            success()
        }
    }

    /// 参与端活动基础信息
    func requestGetActivityBaseInfo(success:@escaping((GXActivityBaseInfoData?) -> Void), failure:@escaping GXFailure) {
        /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
        var apiString: String = ""
        if self.messageType == 1 || self.messageType == 3 {
            apiString = Api_CActivity_GetActivityBaseInfo
        } else {
            apiString = Api_Activity_GetActivityBaseInfo
        }
        let api = GXApi.normalApi(apiString, ["id":self.activityId], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityBaseInfoModel.self, success: { model in
            success(model.data)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}

private extension GXChatViewModel {
    /// 参与端发布活动咨询
    func requestChatSend(text: String, photoAssets: [PhotoAsset], success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["chatContent"] = text
        params["chatPic"] = PhotoAsset.gx_imageUrlsString(assets: photoAssets)
        /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
        var apiMethod: String = ""
        switch self.messageType {
        case 1:
            params["activityId"] = self.activityId
            apiMethod = Api_CAChat_CreateActivityChat
        case 2:
            params["chatId"] = self.chatId
            apiMethod = Api_PAChat_ReplyActivityChat
        case 3:
            params["activityId"] = self.activityId
            apiMethod = Api_CAChat_CreateActivitySignChat
        case 4:
            params["activityId"] = self.activityId
            apiMethod = Api_PAChat_ReplyActivitySignChat
        case 5:
            params["activityId"] = self.activityId
            apiMethod = Api_PAChat_ReplyActivityWorkChat
        default: break
        }
        let api = GXApi.normalApi(apiMethod, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            let item = GXListUserMessagesItem()
            item.updateTime = GXServiceManager.shared.systemDate.string(format: "yyyy-MM-dd HH:mm:ss")
            item.chatContent = text
            item.chatPic = (params["chatPic"] as? String) ?? ""
            if let user = GXUserManager.shared.user {
                item.userId = user.id
                item.nickName = user.nickName
                item.avatarPic = user.avatarPic
            }
            if let data = self?.data {
                data.children.append(item)
            } else {
                self?.data = item
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
    /// 获取成员(1-查询报名成员 2-查询工作人员)
    func requestGetUserLists(type: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        params["type"] = type
        if type == 1 {
            params["pageNum"] = 1
            params["pageSize"] = 10
        }
        var apiMethod = ""
        /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
        if self.messageType == 1 || self.messageType == 3 {
            if type == 2 {
                apiMethod = Api_Activity_GetActivitySignInfo
            } 
            else {
                apiMethod = Api_CActivity_GetActivitySignInfo
            }
        }
        else {
            apiMethod = Api_Activity_GetActivitySignInfo
        }
        let api = GXApi.normalApi(apiMethod, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivitySignInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            guard let data = model.data else {
                success(); return
            }
            if type == 2 {
                for staffsUser in data.activityStaffs {
                    guard GXRoleUtil.isStaff(roleType: staffsUser.roleType) else { continue }
                    self.staffsUserIds.update(with: staffsUser.userId)
                    if self.userList.first(where: { $0.userId == staffsUser.userId }) == nil {
                        let user = GXActivityUser()
                        user.avatarPic = staffsUser.avatarPic
                        user.nickName = staffsUser.nickName
                        user.userId = staffsUser.userId
                        user.phone = staffsUser.phone
                        user.isStaffs = true
                        self.userList.insert(user, at: 0)
                    }
                }
            }
            else {
                guard let activitySigns = data.activitySigns else {
                    success(); return
                }
                for signsUser in activitySigns.list {
                    if self.userList.first(where: { $0.userId == signsUser.userId }) == nil {
                        let user = GXActivityUser()
                        user.avatarPic = signsUser.avatarPic
                        user.nickName = signsUser.nickName
                        user.userId = signsUser.userId
                        user.phone = signsUser.phone
                        user.isStaffs = false
                        self.userList.append(user)
                    }
                }
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
}
