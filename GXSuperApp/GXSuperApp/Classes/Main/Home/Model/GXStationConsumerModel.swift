//
//  GXStationConsumerModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/26.
//

import UIKit
import HandyJSON

class GXStationConsumerTagslistModel: NSObject, HandyJSON {
    var id: Int = 0
    var name: String = ""
    var icon: String = ""

    override required init() {}
}

class GXStationConsumerRowsModel: NSObject, HandyJSON {
    var floor: String = ""
    var serviceFee: CGFloat = 0
    var teslaCount: Int = 0
    var usIdleCount: Int = 0
    var position: String = ""
    var aroundServicesArr = [String]()
    var tags: String = ""
    var occupyFee: String = ""
    var tagsList = [GXStationConsumerTagslistModel]()
    var freeParking: String = ""
    var city: String = ""
    var name: String = ""
    var electricFee: CGFloat = 0
    var aroundFacilitiesList = [GXStationConsumerTagslistModel]()
    var id: Int = 0
    var occupyFlag: String = ""
    var timeZone: Int = 0
    var siteGuidance: String = ""
    var distance: Int = 0
    var teslaIdleCount: Int = 0
    var lat: Double = 0
    var lng: Double = 0
    var aroundServices: String = ""
    var aroundFacilities: String = ""
    var price: CGFloat = 0
    var usCount: Int = 0
    var serviceFeeVip: CGFloat = 0
    var address: String = ""
    //站点状态；PREPARING：准备中，OPENED：已开通，DEACTIVATED：已停用
    var stationStatus: String = ""
    var cooperationStatus: String = ""

    override required init() {}
}

class GXStationConsumerData: NSObject, HandyJSON {
    var total: Int = 0
    var rows = [GXStationConsumerRowsModel]()

    override required init() {}
}

class GXStationConsumerModel: GXBaseModel {
    var data: GXStationConsumerData?
}
