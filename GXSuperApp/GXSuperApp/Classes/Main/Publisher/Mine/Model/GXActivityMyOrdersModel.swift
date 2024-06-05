//
//  GXActivityMyOrdersModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import HandyJSON

class GXActivityMyOrdersPage: NSObject, HandyJSON {
    var list: [GXListMyOrderItem] = []
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXActivityMyOrdersData: NSObject, HandyJSON {
    var orders: GXActivityMyOrdersPage?
    var totalPrice: Float = 0

    override required init() {}
}

class GXActivityMyOrdersModel: GXBaseModel {
    var data: GXActivityMyOrdersData?
}
