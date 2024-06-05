//
//  GXSignActivityModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import HandyJSON

class GXSignActivityData: NSObject, HandyJSON {
    var ticketCode: String = ""
    var orderSn: String = ""
    var totalPrice: Float = 0

    override required init() {}
}

class GXSignActivityModel: GXBaseModel {
    var data: GXSignActivityData?
}
