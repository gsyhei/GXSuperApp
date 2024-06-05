//
//  GXPublishStepViewModel+Add.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/15.
//

import Foundation
import HXPhotoPicker
import MBProgressHUD

extension GXPublishStepViewModel {

    func requestGetActivityAllInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "info_queue")

        group.enter()
        queue.async {
            self.requestGetActivityBaseInfo {
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }
        }
        group.enter()
        queue.async {
            self.requestGetActivityPicInfo {
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }
        }
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                success()
            }
        }
    }

    func requestGetActivityBaseInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Activity_GetActivityBaseInfo, ["id":activityId ?? 0], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityBaseInfoModel.self, success: { model in
            self.infoData = model.data
            self.updateInfoInput()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestGetActivityPicInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Activity_GetActivityPicInfo, ["id":activityId ?? 0], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityPicInfoModel.self, success: { model in
            self.picData = model.data
            self.updateInfoInput()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestEditActivityBaseInfo(data: GXActivityEditBaseInfoData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard let params = data.toJSON() else { return }
        let api = GXApi.normalApi(Api_Activity_UpdateActivityBaseInfo, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestEditActivityPicInfo(data: GXActivityEditPicInfoData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard let params = data.toJSON() else { return }
        let api = GXApi.normalApi(Api_Activity_UpdateActivityPicInfo, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestEditActivityAllInfo(infoData: GXActivityEditBaseInfoData, picData: GXActivityEditPicInfoData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        self.requestEditActivityBaseInfo(data: infoData, success: {[weak self] in
            self?.requestEditActivityPicInfo(data: picData, success: success, failure: failure)
        }, failure: failure)
    }

    // 修改提交 step: 1,2,4
    func requestEditActivity(to vc: UIViewController, step: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let baseInfoData = GXActivityEditBaseInfoData()
        let picInfoData = GXActivityEditPicInfoData()

        self.saveEditStep1(data: baseInfoData)
        self.saveEditStep2(data: baseInfoData)
        baseInfoData.confirmFlag = 1

        if step == 4 {
            let title = "您重新提交，平台需要再次审核\n核通过后，用户才可报名"
            let cancel = "放弃编辑"
            let commit = "提交去审核"
            GXUtil.showAlert(title: title, cancelTitle: cancel, actionTitle: commit) { alert, index in
                if index == 1 {
                    self.requestUploadAll(success: {[weak self] in
                        self?.saveEditStep4(data: picInfoData)
                        self?.requestEditActivityAllInfo(infoData: baseInfoData, picData: picInfoData, success: success, failure: failure)
                    }, failure: failure)
                }
                else {
                    MBProgressHUD.dismiss(for: vc.view)
                }
            }
        }
        else {
            let title = "您重新提交，平台需要再次审核\n核通过后，用户才可报名"
            let cancel = "放弃编辑"
            let commit = "提交去审核"
            GXUtil.showAlert(title: title, cancelTitle: cancel, actionTitle: commit) { alert, index in
                if index == 1 {
                    self.requestEditActivityBaseInfo(data: baseInfoData, success: success, failure: failure)
                }
                else {
                    MBProgressHUD.dismiss(for: vc.view)
                }
            }
        }
    }

}

extension GXPublishStepViewModel {

    func updateInfoInput() {
        if let info = self.infoData {
            // MARK: - 活动提交审核信息Step1

            /// 活动名称
            self.activityName.accept(info.activityName)
            /// 活动类型ID
            self.activityTypeId = info.activityTypeId
            /// 活动日期-开始日期
            self.activityStartDate = Date.date(dateString: info.startDate, format: "yyyyMMdd")
            /// 活动日期-结束日期
            self.activityEndDate = Date.date(dateString: info.endDate, format: "yyyyMMdd")

            /// 活动周期内每天-开始时间
            self.activityAllStartTime = (info.startTime.count > 0) ? info.startTime:"10:00"
            /// 活动周期内每天-结束时间
            self.activityAllEndTime = (info.endTime.count > 0) ? info.endTime:"18:00"

            /// 活动地址
            self.activityLocation = info.address
            /// 活动城市地区
            self.activityCityName = info.cityName
            /// 位置描述
            self.activityLocationDesc.accept(info.addressDesc)
            /// 活动地址-纬度
            self.activityLocationLatitude = info.latitude
            /// 活动地址-经度
            self.activityLocationLongitude = info.longitude

            // MARK: - 活动提交审核信息Step2

            /// 活动参与人数-是否限制
            self.activityNumberOfPeopleChecked = info.limitJoinNum == 1
            /// 活动参与人数-输入
            self.activityNumberOfPeopleInput.accept(info.joinNum)
            /// 活动参与人数-仅VIP可报名
            self.activityVipCanSignUpChecked = info.limitVip == 1
            /// 活动模式及价格-免费报名模式(1-免费报名模式 2-卖票模式)
            self.activitySignUpMode = info.activityMode

            if info.activityMode == 1 {
                /// 标准价-报名开始日期
                self.activitySPFreeSignUpStartDate = Date.date(dateString: info.signBeginDate, format: "yyyyMMdd")
                /// 标准价-报名结束日期
                self.activitySPFreeSignUpEndDate = Date.date(dateString: info.signEndDate, format: "yyyyMMdd")
            }
            if let normalItem = info.activityTickets.first(where: { $0.ticketType == 1 }) {
                /// 标准价-普通用户
                self.activityStandardPriceUserInput.accept(normalItem.normalPrice)
                /// 标准价-VIP用户
                self.activityStandardPriceVipInput.accept(normalItem.vipPrice)
                /// 标准价-报名开始日期
                self.activitySPSignUpStartDate = Date.date(dateString: normalItem.beginDate, format: "yyyyMMdd")
                /// 标准价-报名结束日期
                self.activitySPSignUpEndDate = Date.date(dateString: normalItem.deadlineDate, format: "yyyyMMdd")
            }

            self.activityPreferentialChecked = false
            if let normalItem = info.activityTickets.first(where: { $0.ticketType == 2 }) {
                self.activityPreferentialChecked = true
                /// 早鸟价-普通用户
                self.activityPreferentialPriceUserInput.accept(normalItem.normalPrice)
                /// 早鸟价-VIP用户
                self.activityPreferentialPriceVipInput.accept(normalItem.normalPrice)
                /// 早鸟价-报名开始日期
                self.activityPPSignUpStartDate = Date.date(dateString: normalItem.beginDate, format: "yyyyMMdd")
                /// 早鸟价-报名结束日期
                self.activityPPSignUpEndDate = Date.date(dateString: normalItem.deadlineDate, format: "yyyyMMdd")
            }

            // MARK: - 活动提交审核信息Step4

            /// 活动图片-单张
            self.activityImages = PhotoAsset.gx_photoAssets(pics: self.picData?.listPics)
            /// 活动详情顶部图片-最大9张
            self.activityDetailImages = PhotoAsset.gx_photoAssets(pics: self.picData?.topPics)
            /// 活动详情介绍图片-最大9张
            self.activityDetailDescImages = PhotoAsset.gx_photoAssets(pics: self.picData?.activityDesc)
        }
    }

    func isNeedAudit(data: GXActivityEditBaseInfoData, step: Int) -> Bool {
        guard let info = self.infoData else { return true }

        if data.activityName != info.activityName {
            return true
        }
        if data.activityTypeId != info.activityTypeId {
            return true
        }
        if data.startDate != info.startDate {
            return true
        }
        if data.endDate != info.endDate {
            return true
        }
        if (data.startTime ?? "") != info.startTime {
            return true
        }
        if (data.endTime ?? "") != info.endTime {
            return true
        }
        if data.address != info.address {
            return true
        }
        if data.addressDesc != info.addressDesc {
            return true
        }

        if step >= 2 {
            if data.activityMode != info.activityMode {
                return true
            }
            if data.limitJoinNum != info.limitJoinNum {
                return true
            }
            if data.joinNum != info.joinNum {
                return true
            }
            if data.limitVip != info.limitVip {
                return true
            }
            if data.signBeginDate != info.signBeginDate {
                return true
            }
            if data.signEndDate != info.signEndDate {
                return true
            }
            if data.activityTickets?.count != info.tickets.count {
                return true
            }
            if let info_bzItem = info.activityTickets.first(where: {$0.ticketType == 1}),
               let data_bzItem = data.activityTickets?.first(where: {$0.ticketType == 1}) {
                if info_bzItem.normalPrice != data_bzItem.normalPrice {
                    return true
                }
                if info_bzItem.vipPrice != data_bzItem.vipPrice {
                    return true
                }
            }
            if let info_znItem = info.activityTickets.first(where: {$0.ticketType == 2}),
               let data_znItem = data.activityTickets?.first(where: {$0.ticketType == 2}) {
                if info_znItem.normalPrice != data_znItem.normalPrice {
                    return true
                }
                if info_znItem.vipPrice != data_znItem.vipPrice {
                    return true
                }
            }
        }
        return false
    }

    func saveEditStep1(data: GXActivityEditBaseInfoData) {
        /// 活动ID
        data.activityId = self.activityId
        /// 活动名称
        data.activityName = self.activityName.value
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
            data.startDate = dateStr
        }
        /// 活动日期-结束日期
        if let letActivityEndDate = self.activityEndDate {
            let dateStr = letActivityEndDate.string(format: "yyyyMMdd")
            data.endDate = dateStr
        }
        /// 活动周期内每天-开始时间
        data.startTime = self.activityAllStartTime
        /// 活动周期内每天-结束时间
        data.endTime = self.activityAllEndTime
    }

    func saveEditStep2(data: GXActivityEditBaseInfoData) {
        /// 活动参与人数-是否限制
        data.limitJoinNum = self.activityNumberOfPeopleChecked ? 1:0
        /// 限制人数
        data.joinNum = self.activityNumberOfPeopleInput.value
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

    func saveEditStep4(data: GXActivityEditPicInfoData) {
        /// 活动ID
        data.activityId = self.activityId
        /// 活动图片-单张
        data.listPics = PhotoAsset.gx_imageUrlsString(assets: self.activityImages)
        /// 活动详情顶部图片-最大9张
        data.topPics = PhotoAsset.gx_imageUrlsString(assets: self.activityDetailImages)
        /// 活动详情介绍图片-最大9张
        data.activityDesc = PhotoAsset.gx_imageUrlsString(assets: self.activityDetailDescImages)
    }

    /// 编辑基本资料第1页校验 true为符合提交/下一步
    func isEditBaseInfoPage1Checked() -> Bool {
        if self.activityName.value?.isEmpty ?? true {
            GXToast.showError(text: "请输入活动名称！")
            return false
        }
        if ((self.activityTypeId ?? 0) == 0) {
            GXToast.showError(text: "请选择活动类型！")
            return false
        }
        if (self.activityStartDate == nil) {
            GXToast.showError(text: "请选择开始日期！")
            return false
        }
        if (self.activityEndDate == nil) {
            GXToast.showError(text: "请选择结束日期！")
            return false
        }
        if (self.activityLocation?.isEmpty ?? true) {
            GXToast.showError(text: "请选择活动地址！")
            return false
        }
        if (self.activityLocationDesc.value?.isEmpty ?? true) {
            GXToast.showError(text: "请输入地址描述！")
            return false
        }
        let systemDate = GXServiceManager.shared.systemDate
        let differenceDay = Calendar.current.dateComponents([.day], from: self.activityEndDate!, to: systemDate).day ?? 0
        if differenceDay > 0 {
            GXToast.showError(text: "活动结束日期不能小于今天！")
            return false
        }
        if self.activityStartDate! > self.activityEndDate! {
            GXToast.showError(text: "活动开始日期不能大于结束日期！")
            return false
        }
        return true
    }

    /// 编辑基本资料第2页校验 true为符合提交/下一步
    func isEditBaseInfoPage2Checked() -> Bool {
        if self.activityNumberOfPeopleChecked {
            if self.activityNumberOfPeopleInput.value?.isEmpty ?? true {
                GXToast.showError(text: "请输入活动参与人数！")
                return false
            }
        }
        if self.activitySignUpMode == 1 {
            if self.activitySPFreeSignUpStartDate == nil {
                GXToast.showError(text: "请选择免费-报名开始日期！")
                return false
            }
            if self.activitySPFreeSignUpEndDate == nil {
                GXToast.showError(text: "请选择免费-报名结束日期！")
                return false
            }
        }
        else if self.activitySignUpMode == 2 {
            if self.activityStandardPriceUserInput.value?.isEmpty ?? true {
                GXToast.showError(text: "请输入标准价-普通用户！")
                return false
            }
            if self.activitySPSignUpStartDate == nil {
                GXToast.showError(text: "请选择标准价-报名开始日期！")
                return false
            }
            if self.activitySPSignUpEndDate == nil {
                GXToast.showError(text: "请选择标准价-报名结束日期！")
                return false
            }
            if self.activitySPSignUpStartDate! > self.activitySPSignUpEndDate! {
                GXToast.showError(text: "标准价-报名开始日期不能大于结束日期！")
                return false
            }
            if self.activityPreferentialChecked {
                if self.activityPreferentialPriceUserInput.value?.isEmpty ?? true {
                    GXToast.showError(text: "请输入早鸟价-普通用户！")
                    return false
                }
                if self.activityPPSignUpStartDate == nil {
                    GXToast.showError(text: "请输入早鸟价-报名开始日期！")
                    return false
                }
                if self.activityPPSignUpEndDate == nil {
                    GXToast.showError(text: "请输入早鸟价-报名结束日期！")
                    return false
                }
                if self.activityPPSignUpStartDate! > self.activityPPSignUpEndDate! {
                    GXToast.showError(text: "早鸟价-报名开始日期不能大于结束日期！")
                    return false
                }
                if self.activitySPSignUpStartDate! <= self.activityPPSignUpEndDate! {
                    GXToast.showError(text: "标准价-报名开始日期不能'小于等于'早鸟价-报名结束日期！")
                    return false
                }
            }
        }
        return true
    }

    /// 编辑基本资料第4页校验 true为符合提交/下一步
    func isEditBaseInfoPage4Checked() -> Bool {
        if self.activityImages.count == 0 {
            GXToast.showError(text: "请添加活动图片！")
            return false
        }
        if self.activityDetailImages.count == 0 {
            GXToast.showError(text: "请添加活动详情顶部图片！")
            return false
        }
        if self.activityDetailDescImages.count == 0 {
            GXToast.showError(text: "请添加活动详情介绍图片！")
            return false
        }
        if !self.activityAgreementCheck {
            GXToast.showError(text: "请同意《产品服务协议》！")
            return false
        }
        return true
    }

}
