//
//  GXPtHomeListBannerModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit

import HandyJSON

class GXPtHomeListBannerItem: NSObject, HandyJSON {
    var activityId: Int = 0
    var bannerOrder: Int = 0
    var bannerPic: String = ""
    var bannerStatus: Int = 0
    var bannerTitle: String = ""
    var createTime: String = ""
    var creatorId: Int = 0
    var deleted: Bool = false
    var id: Int = 0
    var linkType: Int = 0
    var otherPage: String = ""
    var remark: String = ""
    var updateTime: String = ""

    override required init() {}
}

class GXPtHomeListBannerModel: GXBaseModel {
    var data: [GXPtHomeListBannerItem] = []
}
