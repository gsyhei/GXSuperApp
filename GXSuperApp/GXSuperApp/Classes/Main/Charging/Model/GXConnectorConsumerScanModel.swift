//
//  GXConnectorConsumerScanModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/5.
//

import UIKit
import HandyJSON

class GXConnectorConsumerScanStationinfoModel: NSObject, HandyJSON {
    var period: String = ""
    var serviceFee: CGFloat = 0
    var prices = [GXStationConsumerDetailPricesItem]()
    var serviceFeeVip: CGFloat = 0
    var id: Int = 0
    var occupyFlag: String = ""
    var freeParking: String = ""
    var occupyFee: CGFloat = 0
    var name: String = ""
    var electricFee: CGFloat = 0

    override required init() {}
}

class GXConnectorConsumerScanData: NSObject, HandyJSON {
    var qrcode: String = ""
    /** 状态；Available-可用、Preparing-准备、Charging-充电、SuspendedEVSE-暂停EVSE、SuspendedEV-暂停EV、
     *       Finishing=完成、Reserved-预订保留、Unavailable-不可用、Faulted-故障
     */
    var status: String = ""
    var pointId: Int = 0
    var currentType: String = ""
    var connectorId: Int = 0
    var pointIdStr: String = ""
    var maxPower: Int = 0
    var connectorName: String = ""
    var memberFlag: String = ""
    var stationInfo: GXConnectorConsumerScanStationinfoModel?
    var connectorIdStr: String = ""

    override required init() {}
}

class GXConnectorConsumerScanModel: GXBaseModel {
    var data: GXConnectorConsumerScanData?
}
