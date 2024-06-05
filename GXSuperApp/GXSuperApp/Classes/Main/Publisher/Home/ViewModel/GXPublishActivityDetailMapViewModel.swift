//
//  GXPublishActivityDetailMapViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/16.
//

import UIKit
import RxRelay
import HXPhotoPicker
import Moya

class GXPublishActivityDetailMapViewModel: GXBaseViewModel {
    /// 活动data
    var activityData: GXActivityBaseInfoData!
    var mapInfoData: GXActivityMapInfoData? {
        didSet {
            if let data = mapInfoData {
                self.mapDescInput.accept(data.mapDesc)
                self.mapImages = PhotoAsset.gx_photoAssets(pics: data.mapPics)
            }
        }
    }
    /// 场地图描述
    var mapDescInput = BehaviorRelay<String?>(value: nil)
    /// 场地图图片-最大9张
    var mapImages: [PhotoAsset] = []

    func requestGetActivityMapInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Activity_GetActivityMapInfo, ["id":self.activityData.id], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityMapInfoModel.self, success: { model in
            self.mapInfoData = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestUpdateActivityMapAll(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        GXApiUtil.requestUploadList(images: self.mapImages, success: {[weak self] in
            self?.requestUpdateActivityMapInfo(success: success, failure: failure)
        }, failure: failure)
    }

}

private extension GXPublishActivityDetailMapViewModel {
    func requestUpdateActivityMapInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["activityId"] = self.activityData.id
        if let desc = self.mapDescInput.value {
            params["mapDesc"] = desc
        }
        params["mapPics"] = PhotoAsset.gx_imageUrlsString(assets: self.mapImages)
        let api = GXApi.normalApi(Api_Activity_UpdateActivityMapInfo, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
