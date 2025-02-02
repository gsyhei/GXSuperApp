//
//  GXUserModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/30.
//

import UIKit
import HandyJSON

class GXUserData: NSObject, HandyJSON {
    var createTime: String = ""
    /// 是否会员
    var memberFlag: GXBOOL = .NO
    var id: String = ""
    var uuid: String = ""
    var updateTime: String = ""
    var memberEndDate: String = ""
    var photo: String = ""
    var nationCode: String = ""
    var phoneNumber: String = ""
    
    required override init() {}
}

class GXUserModel: GXBaseModel {
    var data: GXUserData?
}
