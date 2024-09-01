//
//  GXStationConsumerDetailModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/27.
//

import UIKit
import HandyJSON

class GXStationConsumerDetailTagslistItem: NSObject, HandyJSON {
    var id: Int = 0
    var name: String = ""
    var icon: String = ""

    override required init() {}
}

class GXStationConsumerDetailPricesItem: NSObject, HandyJSON {
    var serviceFee: CGFloat = 0
    var serviceFeeVip: CGFloat = 0
    var priceType: Int = 0
    var periodStart: String = ""
    var type: String = ""
    var periodEnd: String = ""
    var occupyFee: CGFloat = 0
    var electricFee: CGFloat = 0

    override required init() {}
}

class GXStationConsumerDetailData: NSObject, HandyJSON {
    var address: String = ""
    var serviceFee: CGFloat = 0
    var floor: String = ""
    var position: String = ""
    var aroundServicesArr = [String]()
    var tagsList = [GXStationConsumerDetailTagslistItem]()
    var teslaCount: Int = 0
    var occupyFee: CGFloat = 0
    var usIdleCount: Int = 0
    var period: String = ""
    var freeParking: String = ""
    var favoriteFlag: String = ""
    var lng: Double = 0
    var city: String = ""
    var name: String = ""
    var electricFee: CGFloat = 0
    var aroundFacilitiesList = [GXStationConsumerDetailTagslistItem]()
    var id: Int = 0
    var timeZone: Int = 0
    var siteGuidance: String = ""
    var occupyFlag: String = ""
    var memberFlag: String = ""
    var companyName: String = ""
    var teslaIdleCount: Int = 0
    var lat: Double = 0
    var maxPower: Int = 0
    var usCount: Int = 0
    var serviceFeeVip: CGFloat = 0
    var prices = [GXStationConsumerDetailPricesItem]()
    //站点状态；PREPARING：准备中，OPENED：已开通，DEACTIVATED：已停用
    var stationStatus: String = ""
    var cooperationStatus: String = ""
    
    override required init() {}
}

class GXStationConsumerDetailModel: GXBaseModel {
    var data: GXStationConsumerDetailData?
}
