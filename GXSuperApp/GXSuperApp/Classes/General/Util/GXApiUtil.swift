//
//  GXApiUtil.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/16.
//

import UIKit
import HXPhotoPicker
import Moya
import Bugly
import XCGLogger
import MBProgressHUD

class GXApiUtil: NSObject {

    /// 上传图片
    class func requestUploadList(images: [PhotoAsset], success:@escaping(() -> Void), failure:@escaping GXFailure) {
        if images.count == 0 {
            success(); return
        }
        var multipartFormDataArray: [MultipartFormData] = []
        let group = DispatchGroup()
        for index in 0..<images.count {
            let asset = images[index]
            guard (asset.networkImageAsset == nil) else { continue }

            group.enter()
            asset.getImage() { image in
                if let data = image?.dataForCompression(to: SCREEN_SIZE, resizeByte: 1024 * 1024 * 2, isDichotomy: true) {
                    let formData = MultipartFormData(provider: .data(data), name: "files", fileName: "image\(index).jpg", mimeType: "image/jpg")
                    multipartFormDataArray.append(formData)
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global()) {
            guard multipartFormDataArray.count > 0 else { return success() }

            let api = GXApi.uploadApi(Api_File_UploadPics, multipartFormDataArray, [:])
            GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
                guard let dataStr = model.data as? String else { return success() }
                let imageUrlStrs = dataStr.components(separatedBy: ",")
                for urlStr in imageUrlStrs {
                    if let letAsset = images.first(where: { $0.networkImageAsset == nil }) {
                        guard let url = URL(string: urlStr) else { continue }
                        letAsset.networkImageAsset = NetworkImageAsset(thumbnailURL: url, originalURL: url)
                    }
                }
                success()
            }, failure: failure)
        }
    }

    /// 上传头像
    class func requestUploadAvatar(image: UIImage, success:@escaping((String?) -> Void), failure:@escaping GXFailure) {
        guard let data = image.dataForCompression(to: SCREEN_SIZE, resizeByte: 1024 * 1024 * 2, isDichotomy: true) else {
            let error = GXError(code: -1000, info: "图片错误")
            failure(error)
            return
        }
        let formData = MultipartFormData(provider: .data(data), name: "file", fileName: "image.jpg", mimeType: "image/jpg")
        let api = GXApi.uploadApi(Api_User_UploadAvatar, [formData], [:])
        GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            let dataStr = model.data as? String
            success(dataStr)
        }, failure: failure)
    }

    /// 上传极光推送ID
    class func requestUpdateCid() {
        guard GXUserManager.shared.isLogin else { return }
        guard let registrationID = GXUserManager.shared.registrationID else { return }
        
        var params: Dictionary<String, Any> = [:]
        params["cid"] = registrationID
        let api = GXApi.normalApi(Api_User_UpdateCid, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            XCGLogger.info("UpdateCid success")
            GXApiUtil.updateReportError(params: params, isSuccess: true)
        }, failure: { error in
            XCGLogger.info("UpdateCid \(error.localizedDescription)")
            GXApiUtil.updateReportError(params: params, isSuccess: false, errorDesc: error.localizedDescription)
        })
    }

    /// 举报 - 评论类型 chatType 1-回顾留言 2-咨询
    class func requestCreateReportViolation(chatId: Int, chatType: Int, reportingReason: String) {
        MBProgressHUD.showLoading()
        var params: Dictionary<String, Any> = [:]
        params["chatId"] = chatId
        params["chatType"] = chatType
        params["reportingReason"] = reportingReason
        if let userId = GXUserManager.shared.user?.id {
            params["userId"] = userId
        }
        let api = GXApi.normalApi(Api_CReport_CreateReportViolation, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            MBProgressHUD.dismiss()
            GXToast.showSuccess(text: "举报成功")
        }, failure: { error in
            MBProgressHUD.dismiss()
            GXToast.showError(error)
        })
    }

    /// 小红点获取
    class func requestGetTabRedPoint() {
        guard GXUserManager.shared.isLogin else { return }

        var params: Dictionary<String, Any> = [:]
        params["userRole"] = GXUserManager.shared.roleType.rawValue
        let api = GXApi.normalApi(Api_Message_GetTabRedPoint, params, .get)
        GXNWProvider.gx_request(api, type: GXTabRedPointModel.self, success: { model in
            XCGLogger.info("requestGetTabRedPoint success")
            GXUserManager.shared.tabRedPointData = model.data
            NotificationCenter.default.post(name: GX_NotifName_UpdateTabRedPoint, object: nil)
        }, failure: { error in
            GXUserManager.shared.tabRedPointData = GXTabRedPointData()
            XCGLogger.info("requestGetTabRedPoint \(error.localizedDescription)")
        })
    }

    /// 核销门票
    class func requestActivityVerifyTicket(ticketCode: String, completion: GXActionBlock?) {
        MBProgressHUD.showLoading()
        var params: Dictionary<String, Any> = [:]
        params["ticketCode"] = ticketCode
        let api = GXApi.normalApi(Api_Activity_VerifyTicket, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            MBProgressHUD.dismiss()
            if let msgJson = model.data as? Dictionary<String, Any> {
                let activityName = msgJson["activityName"] as? String
                GXUtil.showInfoAlert(title: activityName, message: "核销成功", actionTitle: "好的") { (alert,index) in
                    completion?()
                }
            }
            else if let msgString = model.data as? String {
                if let msgJson = msgString.jsonValueDecoded() as? Dictionary<String, Any> {
                    let activityName = msgJson["activityName"] as? String
                    GXUtil.showInfoAlert(title: activityName, message: "核销成功", actionTitle: "好的") { (alert,index) in
                        completion?()
                    }
                }
                else {
                    GXUtil.showInfoAlert(message: "核销成功", actionTitle: "好的") { (alert,index) in
                        completion?()
                    }
                }
            }
            else {
                GXUtil.showInfoAlert(message: "核销成功", actionTitle: "好的") { (alert,index) in
                    completion?()
                }
            }
        }, failure: { error in
            MBProgressHUD.dismiss()
            if let msgJson = error.localizedDescription.jsonValueDecoded() as? Dictionary<String, Any> {
                let msg = msgJson["msg"] as? String
                let activityName = msgJson["activityName"] as? String
                GXUtil.showInfoAlert(title: activityName, message: "核销失败", info: msg, cancelTitle: "关闭") { (alert,index) in
                    completion?()
                }
            }
            else {
                GXUtil.showInfoAlert(message: "核销失败", info: error.localizedDescription, cancelTitle: "关闭") { (alert,index) in
                    completion?()
                }
            }
        })
    }

    /** 
     * 点击目标 
     * 1-首页电台 
     * 2-首页抢票播报
     * 3-首页活动日历
     * 4-首页进行中活动
     * 5-首页热门活动 
     * 6-首页活动问卷
     * 7-关注TAB
     * 8-分享按钮
     * 9-活动基本信息
     * 10-活动事件 
     * 11-活动场地
     * 12-活动问卷
     * 13-活动回顾
     * 14-发布活动回顾
     */
    class func requestCreateEvent(targetType: Int, activityId: Int? = nil, targetId: Int? = nil) {
        var params: Dictionary<String, Any> = [:]
        params["targetType"] = targetType
        if let activityId = activityId {
            params["activityId"] = activityId
        }
        if let targetId = targetId {
            params["targetId"] = targetId
        }
        let api = GXApi.normalApi(Api_Click_CreateEvent, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            XCGLogger.info("Api_Click_CreateEvent success")
        }, failure: { error in
            XCGLogger.info("Api_Click_CreateEvent \(error.localizedDescription)")
        })
    }

    /// banner点击
    class func requestClickBanner(bannerId: Int) {
        var params: Dictionary<String, Any> = [:]
        params["bannerId"] = bannerId
        let api = GXApi.normalApi(Api_Click_Banner, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            XCGLogger.info("Api_Click_CreateEvent success")
        }, failure: { error in
            XCGLogger.info("Api_Click_CreateEvent \(error.localizedDescription)")
        })
    }

    /// 抢票播报点击
    class func requestClickBroadcast(broadcastId: String) {
        var params: Dictionary<String, Any> = [:]
        params["broadcastId"] = broadcastId
        let api = GXApi.normalApi(Api_Click_Broadcast, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            XCGLogger.info("Api_Click_CreateEvent success")
        }, failure: { error in
            XCGLogger.info("Api_Click_CreateEvent \(error.localizedDescription)")
        })
    }

    /// 更新地理位置
    class func requestUpdateLocation() {
        guard (GXUserManager.shared.token != nil) else { return }
        guard let city = GXLocationManager.shared.cityName else { return }

        var params: Dictionary<String, Any> = [:]
        params["location"] = city
        if let location = GXLocationManager.shared.currentLocation {
            params["latitude"] = location.coordinate.latitude
            params["longitude"] = location.coordinate.longitude
        }
        let api = GXApi.normalApi(Api_User_UpdateLocation, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            XCGLogger.info("Api_User_UpdateLocation success")
        }, failure: { error in
            XCGLogger.info("Api_User_UpdateLocation \(error.localizedDescription)")
        })
    }

}

extension GXApiUtil {

    class func updateReportError(params: Dictionary<String, Any>, isSuccess: Bool, errorDesc: String? = nil) {
        guard Api_BaseUrl.hasPrefix("http://134") else { return }
        var userInfo: Dictionary<String, Any> = [:]
        userInfo["isSuccess"] = isSuccess
        if GXUserManager.shared.isLogin {
            userInfo["account"] = GXUserManager.shared.user?.account
            userInfo["nickName"] = GXUserManager.shared.user?.nickName
            userInfo["phone"] = GXUserManager.shared.user?.phone
        }
        if let errorDesc = errorDesc {
            userInfo["errorDesc"] = errorDesc
        }
        userInfo.merge(params) { (_, new) -> Any in new }
        let error = NSError(domain: "GXError", code: -9001, userInfo: userInfo)
        Bugly.reportError(error)
    }

}
