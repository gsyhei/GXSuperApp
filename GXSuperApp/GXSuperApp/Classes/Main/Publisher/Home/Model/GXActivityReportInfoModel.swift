//
//  GXActivityReportInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit
import HandyJSON

class GXActivityreportsItem: NSObject, HandyJSON {
    var activityId: Int?
    var createTime: String?
    var creatorId: Int?
    var creator: String?
    var avatarPic: String?
    var deleted: Int?
    var id: Int?
    var pics: String?
    var updateTime: String?
    var workProgress: String?

    override required init() {}
}

class GXActivityreportsModel: NSObject, HandyJSON {
    var list: [GXActivityreportsItem] = []
    var pageNum: Int?
    var pageSize: Int?
    var total: Int?
    var totalPage: Int?

    override required init() {}
}

class GXActivityReportInfoData: NSObject, HandyJSON {
    var activityReports: GXActivityreportsModel?

    override required init() {}
}

class GXActivityReportInfoModel: GXBaseModel {
    var data: GXActivityReportInfoData?
}
