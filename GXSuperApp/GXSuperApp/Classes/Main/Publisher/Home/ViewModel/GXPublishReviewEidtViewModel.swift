//
//  GXPublishReviewEidtViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/22.
//

import UIKit
import HXPhotoPicker
import RxRelay

class GXPublishReviewEidtViewModel: GXBaseViewModel {
    /// 活动data
    var activityId: Int = 0
    /// 自己在活动中的角色
    var roleType: String?
    /// 回顾ID
    var reviewId: Int?
    /// 回顾描述
    var reviewDescInput = BehaviorRelay<String?>(value: nil)
    /// 回顾图片-最大9张
    var reviewImages: [PhotoAsset] = []
    /// 回顾data
    var data: GXActivityreviewsListItem? {
        didSet {
            guard let item = data else { return }
            self.reviewId = item.id
            self.reviewDescInput.accept(item.reviewTitle)
            self.reviewImages = PhotoAsset.gx_photoAssets(pics: item.reviewPics)
        }
    }

    func requestSubmitReview(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        GXApiUtil.requestUploadList(images: self.reviewImages, success: {[weak self] in
            if let reviewId = self?.reviewId {
                self?.requestUpdateReview(id: reviewId, success: success, failure: failure)
            } else {
                self?.requestAddReview(success: success, failure: failure)
            }
        }, failure: failure)
    }

}

private extension GXPublishReviewEidtViewModel {
    func requestAddReview(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let reviewData = GXActivityreviewsListItem()
        reviewData.activityId = self.activityId
        reviewData.userId = GXUserManager.shared.user?.id
        reviewData.reviewTitle = self.reviewDescInput.value
        reviewData.reviewPics = PhotoAsset.gx_imageUrlsString(assets: self.reviewImages)

        guard let params = reviewData.toJSON() else { return }
        let api = GXApi.normalApi(Api_Review_AddReview, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if let reviewId = model.data as? Int {
                self.reviewId = reviewId
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestUpdateReview(id: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let reviewData = GXActivityreviewsListItem()
        reviewData.activityId = self.activityId
        reviewData.id = id
        reviewData.userId = GXUserManager.shared.user?.id
        reviewData.reviewTitle = self.reviewDescInput.value
        reviewData.reviewPics = PhotoAsset.gx_imageUrlsString(assets: self.reviewImages)

        guard let params = reviewData.toJSON() else { return }
        let api = GXApi.normalApi(Api_Review_UpdateReview, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
