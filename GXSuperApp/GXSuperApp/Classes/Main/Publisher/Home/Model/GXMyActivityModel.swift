//
//  GXMyActivityModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit
import HandyJSON

class GXActivityticketlistItem: NSObject, HandyJSON {
    var activityId: Int = 0
    var beginDate: String = ""
    var createTime: String = ""
    var deadlineDate: String = ""
    var id: Int = 0
    var normalPrice: String = ""
    var ticketType: Int = 0
    var title: String = ""
    var updateTime: String = ""
    var vipPrice: String = ""

    override required init() {}
}

class GXMyActivityModel: GXBaseModel {
    var data: [GXActivityBaseInfoData] = []
}
