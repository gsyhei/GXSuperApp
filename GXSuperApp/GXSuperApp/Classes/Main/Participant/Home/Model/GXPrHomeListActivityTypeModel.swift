//
//  GXPrHomeListActivityTypeModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit
import HandyJSON

class GXPrHomeListActivityTypeItem: NSObject, HandyJSON {
    var activityTypeName: String = ""
    var activityTypeOrder: Int = 0
    var activityTypeStatus: Int = 0
    var createTime: String = ""
    var deleted: Bool = false
    var id: String = ""
    var showHomePage: Bool = false
    var updateTime: String = ""

    override required init() {}
}

class GXPrHomeListActivityTypeModel: GXBaseModel {
    var data: [GXPrHomeListActivityTypeItem] = []
}
