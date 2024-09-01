//
//  GXOrderConsumerDoingModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/4.
//

import UIKit
import HandyJSON

class GXOrderConsumerDoingData: NSObject, HandyJSON {
    var id: Int = 0
    var stationId: Int = 0
    var stationName: String = ""
    var city: String = ""
    var orderStatus: GXOrderStatus = .UNKNOWN

    override required init() {}
}

class GXOrderConsumerDoingModel: GXBaseModel {
    var data: GXOrderConsumerDoingData?
}
