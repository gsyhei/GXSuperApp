//
//  GXPublishEventStepViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/18.
//

import UIKit
import RxCocoa
import HXPhotoPicker
import MBProgressHUD
import Moya
import XCGLogger

class GXPublishEventStepViewModel: GXBaseViewModel {
    /// 活动data
    var activityData: GXActivityBaseInfoData!
    /// 事件ID
    var eventId: Int?
    /// 事件详情data
    var detailData: GXPublishEventStepData?

    // MARK: 表单数据

    /// 事件名称
    var eventName = BehaviorRelay<String?>(value: nil)
    /// 事件说明
    var eventDesc = BehaviorRelay<String?>(value: nil)
    /// 事件时间
    var beginDate: Date?
    var beginTime: String?
    var endDate: Date?
    var endTime: String?
    /// 事件报名时间
    var signBeginDate: Date?
    var signBeginTime: String?
    var signEndDate: Date?
    var signEndTime: String?
    /// 事件地点
    var eventAddress = BehaviorRelay<String?>(value: nil)
    /// 事件场地图-最大9张
    var eventMapImages: [PhotoAsset] = []
    /// 事件图描述
    var eventPicsDesc = BehaviorRelay<String?>(value: nil)
    /// 事件描述图-最大9张
    var eventDescImages: [PhotoAsset] = []

    /// 获取事件详情
    func requestGetEventDetail(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Event_GetEventDetail, ["eventId":eventId ?? 0], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXPublishGetEventDetailModel.self, success: { model in
            self.detailData = model.data
            self.updateEventStepData()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 添加事件
    func requestAllLoadAddEvent(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        self.requestUploadAll(success: {[weak self] in
            let eventData = GXPublishEventStepData()
            self?.saveEventStepData(data: eventData)
            self?.requestAddEvent(data: eventData, success: success, failure: failure)
        }, failure: failure)
    }

    /// 编辑事件
    func requestAllLoadUpdateEvent(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        self.requestUploadAll(success: {[weak self] in
            let eventData = GXPublishEventStepData()
            self?.saveEventStepData(data: eventData)
            self?.requestUpdateEvent(data: eventData, success: success, failure: failure)
        }, failure: failure)
    }

    /// 启用/禁用事件
    func requestModifyEventStatus(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Event_ModifyEventStatus, ["eventId":self.eventId ?? 0], .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if self.detailData?.eventStatus == 1 {
                self.detailData?.eventStatus = 0
            } else {
                self.detailData?.eventStatus = 1
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 发送中奖消息
    func requestSendAwardMessage(data: GXPublishEventsignsData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = data.id ?? 0
        params["eventReward"] = data.eventReward ?? ""
        let api = GXApi.normalApi(Api_Event_SendAwardMessage, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}

private extension GXPublishEventStepViewModel {

    func requestAddEvent(data: GXPublishEventStepData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard let params = data.toJSON() else { return }
        let api = GXApi.normalApi(Api_Event_AddEvent, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if let eventId = model.data as? Int {
                self.eventId = eventId
                self.detailData = data
                self.detailData?.eventStatus = 1
                self.updateEventStepData()
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestUpdateEvent(data: GXPublishEventStepData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard let params = data.toJSON() else { return }
        let api = GXApi.normalApi(Api_Event_UpdateEvent, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            self.updateEventStepData()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestUploadAll(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "upload_queue")
        // 上传场地图
        group.enter()
        queue.async {
            GXApiUtil.requestUploadList(images: self.eventMapImages, success: {
                group.leave()
            }) { error in
                failure(error)
                group.leave()
            }
        }
        // 上传描述图
        group.enter()
        queue.async {
            GXApiUtil.requestUploadList(images: self.eventDescImages, success: {
                group.leave()
            }) { error in
                failure(error)
                group.leave()
            }
        }
        group.notify(queue: queue) {
            XCGLogger.info("事件图：上传完成。")
            DispatchQueue.main.async {
                success()
            }
        }
    }

    func saveEventStepData(data: GXPublishEventStepData) {
        data.activityId = self.activityData.id
        data.id = self.eventId
        data.eventTitle = self.eventName.value
        data.eventDesc = self.eventDesc.value

        if let date = self.beginDate {
            data.beginDate = date.string(format: "yyyyMMdd")
        }
        if let date = self.endDate {
            data.endDate = date.string(format: "yyyyMMdd")
        }
        data.beginTime = self.beginTime
        data.endTime = self.endTime

        if let date = self.signBeginDate {
            data.signBeginDate = date.string(format: "yyyyMMdd")
        }
        if let date = self.signEndDate {
            data.signEndDate = date.string(format: "yyyyMMdd")
        }
        data.signBeginTime = self.signBeginTime
        data.signEndTime = self.signEndTime

        data.address = self.eventAddress.value
        data.eventPicsDesc = self.eventPicsDesc.value

        data.eventMaps = PhotoAsset.gx_imageUrlsString(assets: self.eventMapImages)
        data.eventPics = PhotoAsset.gx_imageUrlsString(assets: self.eventDescImages)

        data.eventSigns = self.detailData?.eventSigns
    }

    func updateEventStepData() {
        guard let data = self.detailData else { return }

        self.eventName.accept(data.eventTitle)
        self.eventDesc.accept(data.eventDesc)

        self.beginDate = Date.date(dateString: data.beginDate ?? "", format: "yyyyMMdd")
        self.beginTime = data.beginTime
        self.endDate = Date.date(dateString: data.endDate ?? "", format: "yyyyMMdd")
        self.endTime = data.endTime

        self.signBeginDate = Date.date(dateString: data.signBeginDate ?? "", format: "yyyyMMdd")
        self.signBeginTime = data.beginTime
        self.signEndDate = Date.date(dateString: data.signEndDate ?? "", format: "yyyyMMdd")
        self.signEndTime = data.endTime

        self.eventAddress.accept(data.address)
        self.eventPicsDesc.accept(data.eventPicsDesc)

        /// 事件场地图-最大9张
        self.eventMapImages = PhotoAsset.gx_photoAssets(pics: data.eventMaps)
        /// 事件描述图-最大9张
        self.eventDescImages = PhotoAsset.gx_photoAssets(pics: data.eventPics)
    }

}
