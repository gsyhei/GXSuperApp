//
//  GXStationConsumerPriceModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/9.
//

import UIKit
import HandyJSON

class GXStationConsumerPriceData: HandyJSON {
    var period: String = ""
    var electricFee: CGFloat = 0
    var serviceFee: CGFloat = 0
    var serviceFeeVip: CGFloat = 0
    var occupyFee: CGFloat = 0
    var prices = [GXStationConsumerDetailPricesItem]()
    
    required init() {}
}

class GXStationConsumerPriceModel: GXBaseModel {
    var data: GXStationConsumerPriceData?
}
