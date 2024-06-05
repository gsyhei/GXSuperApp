//
//  GXListMyOrderModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/10.
//

import UIKit
import HandyJSON

class GXListMyOrderItem: NSObject, HandyJSON {
    var activityId: Int = 0
    var activityName: String = ""
    var activityShapshot: String = ""
    var activityTypeName: String = ""
    var createTime: String = ""
    var deleted: Int = 0
    var id: Int = 0
    var listPics: String = ""
    var orderSn: String = ""
    var orderStatus: Int = 0
    var paidTime: String = ""
    var paidType: Int = 0
    var platformRevenue: Int = 0
    var quantity: Int = 0
    var settlementStatus: Int = 0
    var ticketStatus: Int = 0
    var totalPrice: Float = 0
    var transactionId: String = ""
    var unitPrice: Float = 0
    var updateTime: String = ""
    var userId: Int = 0
    var verifyTime: String = ""

    override required init() {}
}

class GXListMyOrderData: NSObject, HandyJSON {
    var list = [GXListMyOrderItem]()
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXListMyOrderModel: GXBaseModel {
    var data: GXListMyOrderData?
}
