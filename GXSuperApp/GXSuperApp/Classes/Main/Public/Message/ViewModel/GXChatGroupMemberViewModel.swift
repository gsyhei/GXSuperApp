//
//  GXChatGroupMemberViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/24.
//

import UIKit

class GXChatGroupMemberViewModel: GXBaseViewModel {
    /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
    var messageType: Int = 0
    /// 活动ID
    var activityId: Int = 0
    /// 成员
    var userList: [GXActivityUser] = []
    /// 工作人员ID
    var staffsUserIds: Set<Int> = []

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
        group.enter()
        self.requestGetUserLists(type: 1, success: {
            group.leave()
        }, failure: { error in
            failure(error)
            group.leave()
        })
        group.notify(queue: DispatchQueue.main) {
            success()
        }
    }
}

extension GXChatGroupMemberViewModel  {
    /// 获取成员(1-查询报名成员 2-查询工作人员)
    func requestGetUserLists(type: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        params["type"] = type
        // 3-报名群(参与端) 4-报名群(发布端)
        var apiMethod = ""
        if self.messageType == 3 {
            if type == 2 {
                apiMethod = Api_Activity_GetActivitySignInfo
            } 
            else {
                apiMethod = Api_CActivity_GetActivitySignInfo
            }
        }
        else if self.messageType == 4 {
            apiMethod = Api_Activity_GetActivitySignInfo
        }
        else { return }

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
                    if self.staffsUserIds.first(where: { $0 == signsUser.userId }) == nil {
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
