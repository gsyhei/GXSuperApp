//
//  GXUserHomepageModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/8.
//

import UIKit
import HandyJSON

class GXActivitycommonpageModel: NSObject, HandyJSON {
    var list: [GXCalendarActivityItem] = []
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXUserHomepageData: NSObject, HandyJSON {
    var activityCommonPage: GXActivitycommonpageModel?
    var avatarPic: String = ""
    var expertFlag: Int = 0
    var fansFlag: Int = 0
    var fansNum: Int = 0
    var nickName: String = ""
    var officialFlag: Int = 0
    var orgAccreditationFlag: Int = 0
    var personalIntroduction: String = ""
    var realnameFlag: Int = 0
    var userId: String = ""
    var userMale: Int = 0
    var vipFlag: Int = 0

    override required init() {}
}

class GXUserHomepageModel: GXBaseModel {
    var data: GXUserHomepageData?
}
