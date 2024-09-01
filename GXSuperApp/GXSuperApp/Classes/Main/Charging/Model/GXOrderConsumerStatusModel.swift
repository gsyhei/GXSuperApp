//
//  GXOrderConsumerStatusModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/31.
//

import UIKit
import HandyJSON

class GXOrderConsumerStatusData: NSObject, HandyJSON {
    var status: GXChargingStatus = .UNKNOWN
    var orderStatus: GXOrderStatus = .UNKNOWN

    override required init() {}
}

class GXOrderConsumerStatusModel: GXBaseModel {
    var data: GXOrderConsumerStatusData?
}
