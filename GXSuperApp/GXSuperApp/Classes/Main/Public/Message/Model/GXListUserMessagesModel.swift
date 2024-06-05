//
//  GXListUserMessagesModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit
import HandyJSON

class GXListUserMessagesItem: NSObject, HandyJSON {
    var activityId: Int = 0
    var activityName: String = ""
    var avatarPic: String = ""
    var chatContent: String = ""
    var chatPic: String = ""
    var chatType: Int = 0
    var children = [GXListUserMessagesItem]()
    var createTime: String = ""
    var deleted: Int = 0
    var id: Int = 0
    var listPics: String = ""
    var nickName: String = ""
    var parentId: Int = 0
    var redPoint: Bool = true //redPoint =1展示小红点
    var staffId: Int = 0
    var updateTime: String = ""
    var userId: Int = 0
    var setTop: Int = 0

    override required init() {}
}

class GXListUserMessagesData: NSObject, HandyJSON {
    var list = [GXListUserMessagesItem]()
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXListUserMessagesModel: GXBaseModel {
    var data: GXListUserMessagesData?
}

class GXChatConsultModel: GXBaseModel {
    var data: GXListUserMessagesItem?
}
