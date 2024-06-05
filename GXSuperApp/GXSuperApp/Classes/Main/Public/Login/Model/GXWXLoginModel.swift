//
//  GXWXLoginModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/29.
//

import UIKit
import HandyJSON

class GXWXUserData: NSObject, HandyJSON {
    var openid: String = ""
    var nickname: String = ""
    var sex: Int = 0
    var language: String = ""
    var city: String = ""
    var province: String = ""
    var country: String = ""
    var headimgurl: String = ""
    var privilege = [Any]()
    var unionid: String = ""

    required override init() {}
}

class GXWXLoginData: NSObject, HandyJSON {
    var accessToken: String = ""
    var openid: String = ""
    var token: String = ""

    required override init() {}
}
class GXWXLoginModel: GXBaseModel {
    var data: GXWXLoginData?
}
