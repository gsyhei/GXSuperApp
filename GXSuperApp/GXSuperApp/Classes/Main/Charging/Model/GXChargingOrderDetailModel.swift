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
    var price: CGFloat = 0
    var fee: CGFloat = 0

    override required init() {}
}

class GXChargingOrderDetailData: NSObject, HandyJSON {
    var id: Int = 0
    var orderNo: Int = 0
    var stationId: Int = 0
    var stationName: String = ""
    var pointId: Int = 0
    var pointIdStr: String = ""
    var connectorId: Int = 0
    var connectorIdStr: String = ""
    var qrcode: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var occupyStartTime: String = ""
    var occupyEndTime: String = ""
    var carNumber: String = ""
    var orderStatus: String = ""
    var meterTotal: CGFloat = 0
    var powerFee: CGFloat = 0
    var serviceFee: CGFloat = 0
    var occupyFee: CGFloat = 0
    var totalFee: CGFloat = 0
    var actualFee: CGFloat = 0
    var payTime: String = ""
    var payType: String = ""
    var chargingFeeDetails = [GXChargingfeedetailsModel]()
    var occupyFreePeriod: String = ""
    var occupyFeeDetails = [GXOccupyfeedetailsModel]()
    var exemptType: String = ""
    var complainAvailable: Bool?
    var complainId: String = ""
    var freeParking: String = ""
    var chargingDuration: String = ""
    var power: Int = 0
    var voltage: Int = 0
    var current: Int = 0
    var soc: Int = 0
    var countdown: Int = 0
    var occupyFlag: String = ""
    var occupyPrice: CGFloat = 0

    override required init() {}
}

class GXChargingOrderDetailModel: GXBaseModel {
    var data: GXChargingOrderDetailData?
}
