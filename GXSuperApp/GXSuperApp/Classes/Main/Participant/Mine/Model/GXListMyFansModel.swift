//
//  GXListMyFansModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit
import HandyJSON

class GXListMyFansItem: NSObject, HandyJSON {
    var avatarPic: String = ""
    var followEachOther: Bool = false
    var id: String = ""
    var nickName: String = ""
    var personalIntroduction: String = ""
    var isDelete: Bool = false

    override required init() {}
}

class GXListMyFansData: NSObject, HandyJSON {
    var list = [GXListMyFansItem]()
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXListMyFansModel: GXBaseModel {
    var data: GXListMyFansData?
}
