//
//  GXMinePrAccreditationViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import HXPhotoPicker
import RxRelay

class GXMinePrAccreditationViewModel: GXBaseViewModel {
    /// 机构名称
    var descInput = BehaviorRelay<String?>(value: nil)
    /// 机构证书图片-最大9张
    var images: [PhotoAsset] = []
    /// 机构data
    var data: GXGetOrgAccreditationData?

    /// 上传图片并提交机构认证
    func requestAllSubmitOrgAccreditation(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        GXApiUtil.requestUploadList(images: self.images, success: {[weak self] in
            self?.requestSubmitOrgAccreditation(success: success, failure: failure)
        }, failure: failure)
    }

    /// 提交机构认证
    func requestSubmitOrgAccreditation(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["orgName"] = self.descInput.value
        params["businessLicense"] = PhotoAsset.gx_imageUrlsString(assets: self.images)
        let api = GXApi.normalApi(Api_ActivityMy_SubmitOrgAccreditation, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 获取机构认证详情
    func requestGetOrgAccreditation(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_ActivityMy_GetOrgAccreditation, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetOrgAccreditationModel.self, success: { model in
            self.data = model.data
            self.updateEditData()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func updateEditData() {
        guard let data = self.data else { return }

        self.descInput.accept(data.orgName)
        self.images = PhotoAsset.gx_photoAssets(pics: data.businessLicense)
    }
}
