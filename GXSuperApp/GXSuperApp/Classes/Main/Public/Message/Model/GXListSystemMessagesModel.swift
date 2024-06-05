//
//  GXListSystemMessagesModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit
import HandyJSON

class GXListSystemMessagesItem: NSObject, HandyJSON {
    var activityId: Int = 0
    var createTime: String = ""
    var deleted: Int = 0
    var id: Int = 0
    var linkUrl: String = ""
    var messageContent: String = ""
    var messageTarget: Int = 0
    var messageType: Int = 0
    var pushId: Int = 0
    var readFlag: Bool = false  //是否展示小红点 0-未读 1-已读
    var receiveId: Int = 0
    var sendId: Int = 0
    var updateTime: String = ""

    override required init() {}
}

class GXListSystemMessagesData: NSObject, HandyJSON {
    var list = [GXListSystemMessagesItem]()
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXListSystemMessagesModel: GXBaseModel {
    var data: GXListSystemMessagesData?
}
