//
//  OrderConsumerComplainDetailModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import HandyJSON

class OrderConsumerComplainDetailType: NSObject, HandyJSON {
    var id: Int = 0
    var name: String = ""
    override required init() {}
}

class OrderConsumerComplainDetailData: NSObject, HandyJSON {
    var types: [OrderConsumerComplainDetailType] = []
    var orderId: Int = 0
    var reason: String = ""
    var id: Int = 0
    var photos = [String]()
    var status: String = ""
    var exemptType: String = ""
    var createTime: String = ""

    override required init() {}
}

class OrderConsumerComplainDetailModel: GXBaseModel {
    var data: OrderConsumerComplainDetailData?
}
