//
//  GXUserAddressPageModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import HandyJSON

class GXUserAddressPageItem: NSObject, HandyJSON, GXCopyable {
    var consigneeAddress: String = ""
    var consigneeName: String = ""
    var consigneePhone: String = ""
    var createTime: String = ""
    var deleted: Int = 0
    var detailedHouseNumber: String = ""
    var defaultAddress: Int = 0 //是否默认地址 1-是 0-否
    var id: Int = 0
    var updateTime: String = ""
    var userId: Int = 0

    override required init() {}
}

class GXUserAddressPageData: NSObject, HandyJSON {
    var list = [GXUserAddressPageItem]()
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXUserAddressPageModel: GXBaseModel {
    var data: GXUserAddressPageData?
}
