//
//  GXHomeListMayBeInterestedModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/21.
//

import UIKit
import HandyJSON

class GXHomeListMayBeInterestedModel: GXBaseModel {
    var data: [GXListMyFansItem] = []
}

class GXHomeFollowActivityData: NSObject, HandyJSON {
    var list: [GXActivityBaseInfoData] = []
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}
class GXHomeFollowActivityModel: GXBaseModel {
    var data: GXHomeFollowActivityData?
}
