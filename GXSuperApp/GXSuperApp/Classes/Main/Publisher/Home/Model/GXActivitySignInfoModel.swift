//
//  GXActivitySignInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/4.
//

import UIKit
import HandyJSON

class GXActivitysignsCellModel: NSObject {
    var item: GXActivitysignsItem
    var isChecked: Bool = false

    init(item: GXActivitysignsItem) {
        self.item = item
        self.isChecked = (item.signStatus == 1)
    }
}

class GXActivitysignsItem: NSObject, HandyJSON, GXCopyable {
    var activityId: Int = 0
    var avatarPic: String = ""
    var createTime: String = ""
    var id: Int = 0
    var nickName: String = ""
    var operatorId: Int = 0
    var operatorTime: String = ""
    var orderId: Int = 0
    var paidMoney: Float = 0
    var phone: String = ""
    var signStatus: Int = 0 //报名状态 0-待审核 1-成功 -2-失败 -1-移除
    var signTime: String = ""
    var updateTime: String = ""
    var userId: Int = 0
    var verifyFlag: Int = 0
    var vipFlag: Int = 0

    override required init() {}
}

class GXActivitysignsModel: NSObject, HandyJSON {
    var list: [GXActivitysignsItem] = []
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXActivitystaffsModel: NSObject, HandyJSON, GXCopyable {
    var activityId: Int = 0
    var avatarPic: String = ""
    var createTime: String = ""
    var id: Int = 0
    var nickName: String = ""
    var phone: String = ""
    var roleType: String = ""
    var updateTime: String = ""
    var userId: Int = 0

    override required init() {}
}

class GXActivitySignInfoData: NSObject, HandyJSON {
    var activityMode: Int = 0
    var activitySigns: GXActivitysignsModel?
    var activityStaffs: [GXActivitystaffsModel] = []
    var joinNum: Int = 0
    var limitJoinNum: Int = 0
    var limitVip: Int = 0

    override required init() {}
}

class GXActivitySignInfoModel: GXBaseModel {
    var data: GXActivitySignInfoData?
}


class GXActivityUser: NSObject, GXCopyable {
    var avatarPic: String = ""
    var nickName: String = ""
    var userId: Int = 0
    var phone: String = ""
    var isStaffs: Bool = false //是否工作人员

    override required init() {}
}
