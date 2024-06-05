//
//  GXPublishActivityDetailViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/11.
//

import UIKit
import HXPhotoPicker

class GXPublishActivityDetailViewModel: GXBaseViewModel {
    var activityId: Int = 0
    var isOpenDetail: Bool = false
    var activityRuleInfoData: GXActivityRuleInfoData?
    var infoData: GXActivityBaseInfoData?
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
    var descAssets: [PhotoAsset] = []
    var listAssets: [PhotoAsset] = []
    var topAssets: [PhotoAsset] = []

    lazy var bottomTitles: [String] = {
        return ["地图", "成员", "问卷调查", "事件活动", "回顾", "财务", "汇报"]
    }()

    func requestGetActivityAllInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let group = DispatchGroup()
        group.enter()
        self.requestGetActivityBaseInfo {
            group.leave()
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

        group.notify(queue: DispatchQueue.main) {
            success()
        }
    }

    /// 活动基础信息
    func requestGetActivityBaseInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Activity_GetActivityBaseInfo, ["id":self.activityId], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityBaseInfoModel.self, success: { model in
            self.infoData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 活动图文信息
    func requestGetActivityPicInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Activity_GetActivityPicInfo, ["id":self.activityId], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityPicInfoModel.self, success: { model in
            self.picData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 获取注意事项
    func requestGetActivityRuleInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Activity_GetActivityRuleInfo, ["id":self.activityId], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityRuleInfoModel.self, success: { model in
            self.activityRuleInfoData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 活动上架/下架( 1-上架 0-下架 )
    func requestSetShelfStatus(success:@escaping((Int) -> Void), failure:@escaping GXFailure) {
        let shelfStatus = (self.infoData?.shelfStatus == 1) ? 0 : 1
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = self.activityId
        params["shelfStatus"] = shelfStatus
        let api = GXApi.normalApi(Api_Activity_SetShelfStatus, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            self.infoData?.shelfStatus = shelfStatus
            success(shelfStatus)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 删除活动
    func requestActivityDelete(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = self.activityId
        let api = GXApi.normalApi(Api_Activity_Delete, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
