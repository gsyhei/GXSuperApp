//
//  GXHomeDictListAvailableModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/26.
//

import UIKit
import HandyJSON

class GXDictListAvailableData: NSObject, HandyJSON {
    var typeId: Int = 0
    var createTime: String = ""
    var status: String = ""
    var id: Int = 0
    var code: String = ""
    var updateTime: String = ""
    var homeFlag: String = ""
    var orderNum: Int = 0
    var name: String = ""
    var icon: String = ""

    override required init() {}
}

class GXDictListAvailableModel: GXBaseModel {
    var data: [GXDictListAvailableData] = []
}
