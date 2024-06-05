//
//  GXPublishMemberViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/4.
//

import UIKit

class GXPublishMemberViewModel: GXBaseViewModel {
    /// 活动data
    var activityData: GXActivityBaseInfoData!
    /// 总数据data -工作人员
    var workerInfoData: GXActivitySignInfoData?
    /// 工作人员列表
    var workerList: [GXActivitystaffsModel] = []
    /// 总数据data -报名人员
    var signInfoData: GXActivitySignInfoData?
    /// 报名人员列表
    private var signList: [GXActivitysignsCellModel] = []
    /// 搜索报名人员列表
    private (set)var searchSignList: [GXActivitysignsCellModel] = []
    /// 自己是否为管理员
    var isMeAdmin: Bool = false
    /// 报名人员全选
    var isAllSelected: Bool {
        return (self.searchSignList.first(where: { $0.isChecked }) != nil)
    }
    /// 报名人数限制
    var joinNum: Int = 0

    /// 获取搜索报名人员列表结果
    func searchSigns(searchText: String?) {
        guard let searchText = searchText, searchText.count > 0 else {
            self.searchSignList = self.signList
            return
        }
        self.searchSignList = self.signList.filter({ $0.item.phone.contains(find: searchText) })
    }

    /// 获取活动成员-工作人员
    func requestGetActivityStaffs(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityData.id
        params["type"] = 2

        let api = GXApi.normalApi(Api_Activity_GetActivitySignInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivitySignInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.workerInfoData = model.data
            if self.workerInfoData?.limitJoinNum == 1 {
                self.joinNum = self.workerInfoData?.joinNum ?? 0
            }
            self.workerList.removeAll()
            var publisherItem: GXActivitystaffsModel?
            for item in self.workerInfoData?.activityStaffs ?? [] {
                if item.userId == GXUserManager.shared.user?.id {
                    self.activityData.roleType = item.roleType
                }
                if GXRoleUtil.isPublisher(roleType: item.roleType) {
                    publisherItem = item
                }
                else if GXRoleUtil.isPublisher(roleType: item.roleType) {
                    self.workerList.insert(item, at: 0)
                }
                else {
                    self.workerList.append(item)
                }
            }
            if let publisherItem = publisherItem {
                self.workerList.insert(publisherItem, at: 0)
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 查询报名成员
    func requestGetActivitySignInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityData.id
        params["type"] = 1

        let api = GXApi.normalApi(Api_Activity_GetActivitySignInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivitySignInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.signInfoData = model.data
            guard let signData = model.data?.activitySigns else {
                success(); return
            }
            if self.signInfoData?.limitJoinNum == 1 {
                self.joinNum = self.signInfoData?.joinNum ?? 0
            }
            var selectedList: [GXActivitysignsCellModel] = []
            var noselectList: [GXActivitysignsCellModel] = []
            for item in signData.list {
                let cellModel = GXActivitysignsCellModel(item: item)
                if cellModel.isChecked {
                    selectedList.append(cellModel)
                } else {
                    noselectList.append(cellModel)
                }
            }
            self.signList = selectedList + noselectList
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 添加工作人员
    func requestAddActivityStaff(phone: String, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = self.activityData.id
        params["phone"] = phone
        let api = GXApi.normalApi(Api_Activity_AddActivityStaff, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 编辑活动成员-工作人员
    func requestUpdateActivityStaffInfo(staffs: [GXActivitystaffsModel], success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = self.activityData.id
        params["activityStaffs"] = staffs.toJSON()
        let api = GXApi.normalApi(Api_Activity_UpdateActivityStaffInfo, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 保存报名成功用户(全量)
    func requestUpdateActivitySignInfo(signs: [GXActivitysignsItem], success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var activitySignIds: [Int] = []
        for sign in signs {
            activitySignIds.append(sign.id)
        }
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = self.activityData.id
        params["activitySignIds"] = activitySignIds
        let api = GXApi.normalApi(Api_ActivitySign_SaveSignedInfo, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 报名用户核销(单个)
    func requestVerifyActivitySignInfo(activitySignId: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["activitySignId"] = activitySignId
        let api = GXApi.normalApi(Api_ActivitySign_VerifyActivitySignInfo, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
