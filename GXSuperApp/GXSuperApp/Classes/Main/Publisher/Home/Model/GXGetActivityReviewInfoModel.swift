//
//  GXGetActivityReviewInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/21.
//

import UIKit
import HandyJSON

class GXActivityreviewsListItem: NSObject, HandyJSON {
    var activityId: Int?
    var createTime: String?
    var id: Int?
    var reviewPics: String?
    var reviewStatus: Int?
    var reviewTitle: String?
    var updateTime: String?
    var userId: Int?
    var avatarPic: String?
    var nickName: String?
    var setTop: Int?

    override required init() {}
}
class GXActivityreviewsData: NSObject, HandyJSON {
    var list: Array<GXActivityreviewsListItem> = []
    var pageNum: Int = 0
    var pageSize: Int  = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXGetActivityReviewInfoData: NSObject, HandyJSON {
    var activityReviews: GXActivityreviewsData?

    override required init() {}
}

class GXGetActivityReviewInfoModel: GXBaseModel{
    var data: GXGetActivityReviewInfoData?
}


