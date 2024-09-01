//
//  GXFavoriteConsumerListModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import HandyJSON

class GXFavoriteConsumerListItem: NSObject, HandyJSON {
    var usIdleCount: Int = 0
    var stationId: Int = 0
    var occupyFee: Int = 0
    var freeParking: String = ""
    var teslaCount: Int = 0
    var occupyFlag: String = ""
    var price: CGFloat = 0
    var teslaIdleCount: Int = 0
    var usCount: Int = 0
    var distance: Int = 0
    var aroundFacilities = ""
    var name: String = ""
    var aroundFacilitiesList: [GXStationConsumerTagslistModel] = []
    //站点状态；PREPARING：准备中，OPENED：已开通，DEACTIVATED：已停用
    var stationStatus: String = "OPENED"
    var cooperationStatus: String = ""
    
    required override init() {}
}

class GXFavoriteConsumerListData: NSObject, HandyJSON {
    var total: Int = 0
    var rows: [GXFavoriteConsumerListItem] = []
    
    override required init() {}
}

class GXFavoriteConsumerListModel: GXBaseModel {
    var data: GXFavoriteConsumerListData?
}
