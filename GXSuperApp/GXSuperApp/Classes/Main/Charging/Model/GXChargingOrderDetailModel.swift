//
//  GXChargingOrderDetailModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/8.
//

import UIKit
import HandyJSON

class GXChargingfeedetailsModel: NSObject, HandyJSON {
    var periodStart: String = ""
    var periodEnd: String = ""
    var periodType: String = ""
    var meter: CGFloat = 0
    var electricPrice: CGFloat = 0
    var servicePrice: CGFloat = 0
    var totalFee: CGFloat = 0
    
    override required init() {}
}

class GXOccupyfeedetailsModel: NSObject, HandyJSON {
    var periodStart: String = ""
    var periodEnd: String = ""
    var minutes: Int = 0
    var price: String = ""
    var fee: CGFloat = 0
    
    override required init() {}
}

class GXChargingOrderDetailData: NSObject, HandyJSON {
    var id: Int = 0
    var orderNo: String = ""
    var stationId: Int = 0
    var stationName: String = ""
    var pointId: Int = 0
    var pointIdStr: String = ""
    var connectorId: Int = 0
    var connectorIdStr: String = ""
    var qrcode: String = ""
    var favoriteFlag: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var occupyStartTime: String = ""
    var occupyEndTime: String = ""
    var carNumber: String = ""
    var orderStatus: GXOrderStatus = .UNKNOWN
    var meterTotal: String = ""
    var powerFee: CGFloat = 0
    var serviceFee: CGFloat = 0
    var occupyFee: String = ""
    var totalFee: Float = 0
    var actualFee: String = ""
    var payTime: String = ""
    var payType: GXOrderPayType = .BALANCE
    var chargingFeeDetails = [GXChargingfeedetailsModel]()
    var occupyFreePeriod: String = ""
    var occupyFeeDetails = [GXOccupyfeedetailsModel]()
    var exemptType: String = ""
    var complainAvailable: Bool = false
    var complainId: String = ""
    var freeParking: String = ""
    var chargingDuration: Int = 0
    var power: Int = 0
    var voltage: Int = 0
    var current: Int = 0
    var soc: Int = 0
    var countdown: Int = 0
    var occupyFlag: String = ""
    var occupyPrice: String = ""
    
    override required init() {}
}

class GXChargingOrderDetailModel: GXBaseModel {
    var data: GXChargingOrderDetailData?
}
