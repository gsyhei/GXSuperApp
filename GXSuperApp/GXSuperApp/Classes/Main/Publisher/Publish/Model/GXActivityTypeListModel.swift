//
//  GXActivityTypeListModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/30.
//

import UIKit
import HandyJSON

class GXActivityTypeItem: NSObject, HandyJSON {
    var activityTypeName: String = ""
    var activityTypeOrder: Int = 0
    var activityTypeStatus: Int = 0
    var createTime: String = ""
    var deleted: Int = 0
    var id: Int = 0
    var showHomePage: Int = 0
    var updateTime: String = ""

    override required init() {}
}

class GXActivityTypeListModel: GXBaseModel {
    var data:[GXActivityTypeItem] = []
}
