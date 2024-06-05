//
//  GXPrHomeListSearchModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import HandyJSON

class GXPrHomeListSearchItem: NSObject, HandyJSON {
    var createTime: String = ""
    var deleted: Int = 0
    var id: Int = 0
    var searchWord: String = ""
    var updateTime: String = ""
    var userId: Int = 0

    override required init() {}
}

class GXPrHomeListSearchModel: GXBaseModel {
    var data: [GXPrHomeListSearchItem] = []
}

class GXPrHomeHotListSearchModel: GXBaseModel {
    var data: [GXActivityBaseInfoData] = []
}
