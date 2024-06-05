//
//  GXUserInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/28.
//

import UIKit
import HandyJSON

class GXUserInfoData: NSObject, HandyJSON {
    var account: String = ""
    var avatarPic: String = ""
    var birthday: String = ""
    var businessLicense: String = ""
    var createTime: String = ""
    var deleted: Int = 0
    var expertFlag: Int = 0
    var fansNum: Int = 0
    var favoriteNum: Int = 0
    var followNum: Int = 0
    var id: Int = 0
    var idNo: String = ""
    var inviteCode: String = ""
    var inviteId: Int = 0
    var latitude: Int = 0
    var location: String = ""
    var loginIp: String = ""
    var loginTime: String = ""
    var longitude: Int = 0
    var nickName: String = ""
    var officialFlag: Int = 0
    var openid: String = ""
    var orgAccreditationFlag: Int = 0
    var orgName: String = ""
    var password: String = ""
    var personalIntroduction: String = ""
    var phone: String = ""
    var realName: String = ""
    var realnameFlag: Int = 0
    var updateTime: String = ""
    var userMale: Int = 0
    var userStatus: Int = 0
    var vipFlag: Bool = false

    override required init() {}
}

class GXUserInfoModel: GXBaseModel {
    var data: GXUserInfoData?
}
