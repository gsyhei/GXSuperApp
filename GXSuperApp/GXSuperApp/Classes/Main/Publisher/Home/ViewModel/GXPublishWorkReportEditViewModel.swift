//
//  GXPublishWorkReportEditViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit

import HXPhotoPicker
import RxRelay

class GXPublishWorkReportEditViewModel: GXBaseViewModel {
    /// 活动id
    var activityId: Int = 0
    /// 工作汇报ID
    var reportId: Int?
    /// 工作汇报描述
    var workProgressInput = BehaviorRelay<String?>(value: nil)
    /// 工作汇报图片-最大9张
    var reportImages: [PhotoAsset] = []
    /// 工作汇报data
    var data: GXActivityreportsItem? {
        didSet {
            guard let item = data else { return }
            self.reportId = item.id
            self.workProgressInput.accept(item.workProgress)
            self.reportImages = PhotoAsset.gx_photoAssets(pics: item.pics)
        }
    }

    func requestSubmitReport(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        GXApiUtil.requestUploadList(images: self.reportImages, success: {[weak self] in
            if let reportId = self?.reportId {
                self?.requestUpdateReport(id: reportId, success: success, failure: failure)
            } else {
                self?.requestAddReport(success: success, failure: failure)
            }
        }, failure: failure)
    }

}

private extension GXPublishWorkReportEditViewModel {
    func requestAddReport(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let reportData = GXActivityreportsItem()
        reportData.activityId = self.activityId
        reportData.creatorId = GXUserManager.shared.user?.id
        reportData.workProgress = self.workProgressInput.value
        reportData.pics = PhotoAsset.gx_imageUrlsString(assets: self.reportImages)

        guard let params = reportData.toJSON() else { return }
        let api = GXApi.normalApi(Api_Report_AddReport, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if let reportId = model.data as? Int {
                self.reportId = reportId
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestUpdateReport(id: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let reportData = GXActivityreportsItem()
        reportData.id = id
        reportData.activityId = self.activityId
        reportData.creatorId = GXUserManager.shared.user?.id
        reportData.workProgress = self.workProgressInput.value
        reportData.pics = PhotoAsset.gx_imageUrlsString(assets: self.reportImages)

        guard let params = reportData.toJSON() else { return }
        let api = GXApi.normalApi(Api_Report_UpdateReport, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
