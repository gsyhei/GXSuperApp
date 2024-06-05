//
//  GXListMyFavoriteModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit
import HandyJSON

class GXListMyFavoriteData: NSObject, HandyJSON {
    var list = [GXCalendarActivityItem]()
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXListMyFavoriteModel: GXBaseModel {
    var data: GXListMyFavoriteData?
}
