//
//  GXParticipantActivityDetailViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit
import HXPhotoPicker

class GXParticipantActivityDetailViewModel: GXBaseViewModel {
    var activityId: Int = 0
    var isOpenDetail: Bool = false
    var infoData: GXActivityBaseInfoData? {
        didSet {
            guard let info = infoData else { return }
            // 是否已报名 1-是 0-否
            if info.signFlag == 1 {
                // 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过
                self.headerTitles = ["详情", "问卷", "事件", "回顾"]
                self.bottomTitles = ["问卷", "事件", "回顾"]
            }
            else {
                self.headerTitles = ["详情", "回顾"]
                self.bottomTitles = ["回顾"]
            }
        }
    }
    var picData: GXActivityPicInfoData? {
        didSet {
            guard let data = self.picData else { return }
            let assets = PhotoAsset.gx_photoAssets(pics: data.activityDesc)
            for asset in assets {
                guard let urlStr = asset.networkImageAsset?.originalURL.absoluteString else { return }
                if (self.descAssets.first(where: {$0.networkImageAsset?.originalURL.absoluteString == urlStr}) == nil) {
                    self.descAssets.append(asset)
                }
            }
            self.listAssets = PhotoAsset.gx_photoAssets(pics: data.listPics)
            self.topAssets = PhotoAsset.gx_photoAssets(pics: data.topPics)
        }
    }
    /// 内容
    var activityRuleInfoData: GXActivityRuleInfoData?
    var questionaireList: [GXPublishQuestionaireDetailData] = []
    var reviewsList: [GXActivityreviewsListItem] = []
    var eventsList: [GXPublishEventStepData] = []

    var descAssets: [PhotoAsset] = []
    var listAssets: [PhotoAsset] = []
    var topAssets: [PhotoAsset] = []
    var headerTitles: [String] = []
    var bottomTitles: [String] = []

    func requestGetActivityAllInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let group = DispatchGroup()

        group.enter()
        self.requestGetActivityBaseInfo {
            if self.infoData?.signFlag == 1 {
                self.requestGetSignUpInfo {
                    group.leave()
                } failure: { error in
                    failure(error)
                    group.leave()
                }
            } else {
                group.leave()
            }
        } failure: { error in
            failure(error)
            group.leave()
        }

        group.enter()
        self.requestGetActivityPicInfo {
            group.leave()
        } failure: { error in
            failure(error)
            group.leave()
        }

        group.enter()
        self.requestGetActivityRuleInfo {
            group.leave()
        } failure: { error in
            failure(error)
            group.leave()
        }

        group.enter()
        self.requestGetActivityReviewInfo {
            group.leave()
        } failure: {  error in
            failure(error)
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            success()
        }
    }

    func requestGetSignUpInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let group = DispatchGroup()
        group.enter()
        self.requestGetActivityQuestionaireInfo {
            group.leave()
        } failure: { error in
            failure(error)
            group.leave()
        }

        group.enter()
        self.requestGetActivityEventInfo {
            group.leave()
        } failure: { error in
            failure(error)
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            success()
        }
    }

    /// 活动基础信息
    func requestGetActivityBaseInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CActivity_GetActivityBaseInfo, ["id":self.activityId], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityBaseInfoModel.self, success: { model in
            self.infoData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 活动图文信息
    func requestGetActivityPicInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CActivity_GetActivityPicInfo, ["id":self.activityId], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityPicInfoModel.self, success: { model in
            self.picData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    // 获取注意事项
    func requestGetActivityRuleInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CActivity_GetActivityRuleInfo, ["id":self.activityId], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityRuleInfoModel.self, success: { model in
            self.activityRuleInfoData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 获取活动问卷
    func requestGetActivityQuestionaireInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        params["shelfStatus"] = 1
        params["pageNum"] = 1
        params["pageSize"] = 1
        let api = GXApi.normalApi(Api_CActivity_GetActivityQuestionaireInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityQuestionaireInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if let questList = model.data?.activityQuestionaires?.list {
                self.questionaireList = questList
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 获取活动事件
    func requestGetActivityEventInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        let api = GXApi.normalApi(Api_CActivity_GetActivityEventInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityEventInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if let event = model.data?.activityEvents.first {
                self.eventsList = [event]
            }
            else if let event = model.data?.finishedActivityEvents.first {
                self.eventsList = [event]
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 获取活动回顾
    func requestGetActivityReviewInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        params["reviewStatus"] = 1
        params["pageNum"] = 1
        params["pageSize"] = 1
        let api = GXApi.normalApi(Api_CActivity_GetActivityReviewInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetActivityReviewInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if let reviewList = model.data?.activityReviews?.list {
                self.reviewsList = reviewList
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 活动报名
    func requestSignActivity(success:@escaping((GXSignActivityData?) -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = self.activityId
        let api = GXApi.normalApi(Api_CActivity_SignActivity, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXSignActivityModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if (model.data?.ticketCode.count ?? 0) > 0 {
                self.infoData?.signFlag = (self.infoData?.signFlag == 1) ? 0:1
            }
            success(model.data)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 取消/收藏 活动
    func requestAddFavorite(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = self.activityId
        let api = GXApi.normalApi(Api_CActivity_AddFavorite, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            self.infoData?.favoriteFlag = (self.infoData?.favoriteFlag == 1) ? 0:1
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
