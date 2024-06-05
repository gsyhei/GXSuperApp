//
//  GXMineFeedbackViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import HXPhotoPicker
import RxRelay

class GXMineFeedbackViewModel: GXBaseViewModel {
    /// 回顾描述
    var descInput = BehaviorRelay<String?>(value: nil)
    /// 回顾图片-最大9张
    var images: [PhotoAsset] = []

    func requestAllFeedbackCreate(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        GXApiUtil.requestUploadList(images: self.images, success: {[weak self] in
            self?.requestFeedbackCreate(success: success, failure: failure)
        }, failure: failure)
    }

    func requestFeedbackCreate(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["feedbackContent"] = self.descInput.value
        params["feedbackPics"] = PhotoAsset.gx_imageUrlsString(assets: self.images)
        params["roleType"] = GXUserManager.shared.roleType.rawValue
        let api = GXApi.normalApi(Api_Feedback_Create, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
}
