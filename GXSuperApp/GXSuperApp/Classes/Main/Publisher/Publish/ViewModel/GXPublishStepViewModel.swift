//
//  GXPublishStep1ViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/30.
//

import UIKit
import RxCocoa
import HXPhotoPicker
import MBProgressHUD
import Moya
import XCGLogger

class GXPublishStepViewModel: GXBaseViewModel {
    enum GXPublishEditType {
        /// 无编辑属性
        case none
        /// 草稿编辑
        case draft
        /// 详情编辑
        case detail
    }
    var publishEditType: GXPublishEditType = .none

    // MARK: - 活动详情参数
    var infoData: GXActivityBaseInfoData?
    var picData: GXActivityPicInfoData?

    /// 活动类型
    var activityTypeList: [GXActivityTypeItem] = []
    var activityRuleInfoData: GXActivityRuleInfoData?

    // MARK: - 活动提交审核信息Step1
    /// 活动ID
    var activityId: Int?
    /// 活动名称
    var activityName = BehaviorRelay<String?>(value: nil)
    /// 活动类型ID
    var activityTypeId: Int?
    /// 活动日期-开始日期
    var activityStartDate: Date?
    /// 活动日期-结束日期
    var activityEndDate: Date?
    /// 活动周期内每天-开始时间
    var activityAllStartTime: String? = "10:00"
    /// 活动周期内每天-结束时间
    var activityAllEndTime: String? = "18:00"
    /// 活动地址
    var activityLocation: String?
    /// 活动城市地区
    var activityCityName: String?
    /// 位置描述
    var activityLocationDesc = BehaviorRelay<String?>(value: nil)
    /// 活动地址-纬度
    var activityLocationLatitude: Double?
    /// 活动地址-经度
    var activityLocationLongitude: Double?

    // MARK: - 活动提交审核信息Step2

    /// 活动参与人数-是否限制
    var activityNumberOfPeopleChecked: Bool = false
    /// 活动参与人数-输入
    var activityNumberOfPeopleInput = BehaviorRelay<String?>(value: nil)
    /// 活动参与人数-仅VIP可报名
    var activityVipCanSignUpChecked: Bool = false
    /// 活动模式及价格-免费报名模式(1-免费报名模式 2-卖票模式)
    var activitySignUpMode: Int = 1

    /// 免费-报名开始日期
    var activitySPFreeSignUpStartDate: Date?
    /// 免费-报名结束日期
    var activitySPFreeSignUpEndDate: Date?
    
    /// 标准价-普通用户
    var activityStandardPriceUserInput = BehaviorRelay<String?>(value: nil)
    /// 标准价-VIP用户
    var activityStandardPriceVipInput = BehaviorRelay<String?>(value: nil)
    /// 标准价-报名开始日期
    var activitySPSignUpStartDate: Date?
    /// 标准价-报名结束日期
    var activitySPSignUpEndDate: Date?
    
    /// 早鸟价是否选择
    var activityPreferentialChecked: Bool = false
    /// 早鸟价-普通用户
    var activityPreferentialPriceUserInput = BehaviorRelay<String?>(value: nil)
    /// 早鸟价-VIP用户
    var activityPreferentialPriceVipInput = BehaviorRelay<String?>(value: nil)
    /// 早鸟价-报名开始日期
    var activityPPSignUpStartDate: Date?
    /// 早鸟价-报名结束日期
    var activityPPSignUpEndDate: Date?

    // MARK: - 活动提交审核信息Step3

    /// 活动要求
    var activityDressCodeInput = BehaviorRelay<String?>(value: nil)
    /// 活动福利-普通用户福利
    var activityUserWealInput = BehaviorRelay<String?>(value: nil)
    /// 活动福利-VIP用户福利
    var activityVipWealInput = BehaviorRelay<String?>(value: nil)

    // MARK: - 活动提交审核信息Step4

    /// 是否同意《产品服务协议》
    var activityAgreementCheck: Bool = true
    /// 活动图片-单张
    var activityImages: [PhotoAsset] = []
    /// 活动详情顶部图片-最大9张
    var activityDetailImages: [PhotoAsset] = []
    /// 活动详情介绍图片-最大9张
    var activityDetailDescImages: [PhotoAsset] = []
}

extension GXPublishStepViewModel {
    // 获取活动类型
    func requestActivityTypeList(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CActivityType_ListType, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityTypeListModel.self, success: { model in
            self.activityTypeList = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    // 活动保存草稿 step: 1,2,3,4
    func requestAllSaveActivityDraft(step: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let draftData = GXActivityPublishData()
        if step >= 1 {
            self.saveDraftStep1(data: draftData)
        }
        if step >= 2 {
            self.saveDraftStep2(data: draftData)
        }
        if step >= 3 {
            self.saveDraftStep3(data: draftData)
        }
        if step == 4 {
            self.requestUploadAll(success: {[weak self] in
                self?.saveDraftStep4(data: draftData)
                self?.requestSaveActivityDraft(data: draftData, success: success, failure: failure)
            }, failure: failure)
        }
        else {
            self.requestSaveActivityDraft(data: draftData, success: success, failure: failure)
        }
    }

    // 活动提交审核 step: 1,2,3,4
    func requestAllSubmitActivityDirect(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let draftData = GXActivityPublishData()
        self.saveDraftStep1(data: draftData)
        self.saveDraftStep2(data: draftData)
        self.saveDraftStep3(data: draftData)

        self.requestUploadAll(success: {[weak self] in
            self?.saveDraftStep4(data: draftData)
            self?.requestSubmitActivityDirect(data: draftData, success: success, failure: failure)
        }, failure: failure)
    }

    // 活动保存草稿
    func requestSaveActivityDraft(data: GXActivityPublishData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard var params = data.toJSON() else { return }
        if let letactivityId = self.activityId {
            params["id"] = letactivityId
        }
        let api = GXApi.normalApi(Api_Activity_SaveActivityDraft, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if let letActivityId = model.data as? Int {
                self.activityId = letActivityId
                self.publishEditType = .draft
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    // 活动提交审核
    func requestSubmitActivityDirect(data: GXActivityPublishData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        if self.publishEditType == .draft {
            self.requestSaveActivityDraft(data: data, success: {[weak self] in
                self?.requestSubmitActivity(success: success, failure: failure)
            }, failure: failure)
        }
        else {
            guard let params = data.toJSON() else { return }
            let api = GXApi.normalApi(Api_Activity_SubmitActivityDirect, params, .post)
            let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
                if let letActivityId = model.data as? Int {
                    self.activityId = letActivityId
                }
                success()
            }, failure: failure)
            self.gx_addCancellable(cancellable)
        }
    }

    // 活动草稿提交审核
    func requestSubmitActivity(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard let letActivityId = self.activityId else { return }
        let api = GXApi.normalApi(Api_Activity_SubmitActivity, ["activityId": letActivityId], .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    // 上传全部图片
    func  requestUploadAll(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "upload_queue")
        // 上传活动图
        group.enter()
        queue.async {
            GXApiUtil.requestUploadList(images: self.activityImages, success: {
                group.leave()
            }) { error in
                failure(error)
                group.leave()
            }
        }
        // 上传详情顶部图
        group.enter()
        queue.async {
            GXApiUtil.requestUploadList(images: self.activityDetailImages, success: {
                group.leave()
            }) { error in
                failure(error)
                group.leave()
            }
        }
        // 上传详情介绍图
        group.enter()
        queue.async {
            GXApiUtil.requestUploadList(images: self.activityDetailDescImages, success: {
                group.leave()
            }) { error in
                failure(error)
                group.leave()
            }
        }
        group.notify(queue: queue) {
            XCGLogger.info("活动图、详情顶部图：上传完成。")
            DispatchQueue.main.async {
                success()
            }
        }
    }

    // 获取注意事项
    func requestGetActivityRuleInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        if self.activityRuleInfoData != nil {
            success()
            return
        }
        var params: Dictionary<String, Any> = [:]
        if let letActivityId = self.activityId {
            params["id"] = letActivityId
        }
        let api = GXApi.normalApi(Api_Activity_GetActivityRuleInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityRuleInfoModel.self, success: { model in
            self.activityRuleInfoData = model.data
            self.updateActivityRuleInfo()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func updateActivityRuleInfo() {
        guard self.publishEditType != .none else { return }

        // MARK: - 活动提交审核信息Step3
        /// 活动要求
        self.activityDressCodeInput.accept(self.activityRuleInfoData?.dressCode)
        /// 活动福利-普通用户福利
        self.activityUserWealInput.accept(self.activityRuleInfoData?.normalBenefits)
        /// 活动福利-VIP用户福利
        self.activityVipWealInput.accept(self.activityRuleInfoData?.vipBenefits)
    }
}

extension GXPublishStepViewModel {

    func saveDraftStep1(data: GXActivityPublishData) {
        /// 活动名称
        data.activityName = self.activityName.value
        /// 活动ID
        if let letActivityId = self.activityId {
            data.activityId = letActivityId
        }
        /// 活动类型ID
        if let letActivityTypeId = self.activityTypeId {
            data.activityTypeId = letActivityTypeId
        }
        /// 活动地址
        if let letActivityLocation = self.activityLocation {
            data.address = letActivityLocation
        }
        /// 位置描述
        data.addressDesc = self.activityLocationDesc.value
        /// 活动城市地区
        data.cityName = self.activityCityName
        /// 活动地址-纬度
        data.latitude = self.activityLocationLatitude
        /// 活动地址-经度
        data.longitude = self.activityLocationLongitude

        /// 活动日期-开始日期
        if let letActivityStartDate = self.activityStartDate {
            let dateStr = letActivityStartDate.string(format: "yyyyMMdd")
            data.startDate = Int(dateStr)
        }
        /// 活动日期-结束日期
        if let letActivityEndDate = self.activityEndDate {
            let dateStr = letActivityEndDate.string(format: "yyyyMMdd")
            data.endDate = Int(dateStr)
        }
        /// 活动周期内每天-开始时间
        data.startTime = self.activityAllStartTime
        /// 活动周期内每天-结束时间
        data.endTime = self.activityAllEndTime
    }

    func saveDraftStep2(data: GXActivityPublishData) {
        /// 活动参与人数-是否限制
        data.limitJoinNum = self.activityNumberOfPeopleChecked ? 1:0
        /// 限制人数
        if let activityNumberOfPeopleInputValue = self.activityNumberOfPeopleInput.value {
            data.joinNum = Int(activityNumberOfPeopleInputValue)
        }
        /// 仅vip报名 1-是 0-否
        data.limitVip = self.activityVipCanSignUpChecked ? 1:0
        /// 活动模式(1-免费报名模式 2-卖票模式)
        data.activityMode = self.activitySignUpMode

        if self.activitySignUpMode == 1 {
            /// 免费-报名开始日期
            if let letActivitySPFreeSignUpStartDate = self.activitySPFreeSignUpStartDate {
                let dateStr = letActivitySPFreeSignUpStartDate.string(format: "yyyyMMdd")
                data.signBeginDate = dateStr
            }
            /// 免费-报名结束日期
            if let letActivitySPFreeSignUpEndDate = self.activitySPFreeSignUpEndDate {
                let dateStr = letActivitySPFreeSignUpEndDate.string(format: "yyyyMMdd")
                data.signEndDate = dateStr
            }
        }
        else if self.activitySignUpMode == 2 {
            /// 标准价
            let spTicketsItem = GXActivityticketsItem()
            /// 标准价-活动ID
            if let letActivityId = self.activityId {
                spTicketsItem.activityId = letActivityId
            }
            /// 标准价-标题
            spTicketsItem.title = "标准价"
            /// 标准价-票价类型 1-标准价 2-早鸟价
            spTicketsItem.ticketType = 1
            /// 标准价-报名开始日期
            if let letActivitySPSignUpStartDate = self.activitySPSignUpStartDate {
                let dateStr = letActivitySPSignUpStartDate.string(format: "yyyyMMdd")
                spTicketsItem.beginDate = dateStr
            }
            /// 标准价-报名结束日期
            if let letActivitySPSignUpEndDate = self.activitySPSignUpEndDate {
                let dateStr = letActivitySPSignUpEndDate.string(format: "yyyyMMdd")
                spTicketsItem.deadlineDate = dateStr
            }
            /// 标准价-普通用户
            spTicketsItem.normalPrice = self.activityStandardPriceUserInput.value
            /// 标准价-VIP用户
            spTicketsItem.vipPrice = self.activityStandardPriceVipInput.value

            /// 早鸟价
            let ppTicketsItem = GXActivityticketsItem()
            /// 早鸟价-活动ID
            if let letActivityId = self.activityId {
                ppTicketsItem.activityId = letActivityId
            }
            /// 早鸟价-标题
            ppTicketsItem.title = "早鸟价"
            /// 早鸟价-票价类型 1-标准价 2-早鸟价
            ppTicketsItem.ticketType = 2
            /// 早鸟价-报名开始日期
            if let letActivityPPSignUpStartDate = self.activityPPSignUpStartDate {
                let dateStr = letActivityPPSignUpStartDate.string(format: "yyyyMMdd")
                ppTicketsItem.beginDate = dateStr
            }
            /// 早鸟价-报名结束日期
            if let letActivityPPSignUpEndDate = self.activityPPSignUpEndDate {
                let dateStr = letActivityPPSignUpEndDate.string(format: "yyyyMMdd")
                ppTicketsItem.deadlineDate = dateStr
            }
            /// 早鸟价-普通用户
            ppTicketsItem.normalPrice = self.activityPreferentialPriceUserInput.value
            /// 早鸟价-VIP用户
            ppTicketsItem.vipPrice = self.activityPreferentialPriceVipInput.value

            /// 门票信息
            data.activityTickets = []
            if (spTicketsItem.isEditCommit()) {
                data.activityTickets?.append(spTicketsItem)
            }
            if (self.activityPreferentialChecked && ppTicketsItem.isEditCommit()) {
                data.activityTickets?.append(ppTicketsItem)
            }
        }
    }
    
    func saveDraftStep3(data: GXActivityPublishData) {
        /// 活动要求
        data.dressCode = self.activityDressCodeInput.value
        /// 活动福利-普通用户福利
        data.normalBenefits = self.activityUserWealInput.value
        /// 活动福利-VIP用户福利
        data.vipBenefits = self.activityVipWealInput.value
    }

    func saveDraftStep4(data: GXActivityPublishData) {
        /// 活动图片-单张
        data.listPics = PhotoAsset.gx_imageUrlsString(assets: self.activityImages)
        /// 活动详情顶部图片-最大9张
        data.topPics = PhotoAsset.gx_imageUrlsString(assets: self.activityDetailImages)
        /// 活动详情介绍图片-最大9张
        data.activityDesc = PhotoAsset.gx_imageUrlsString(assets: self.activityDetailDescImages)
    }

}
