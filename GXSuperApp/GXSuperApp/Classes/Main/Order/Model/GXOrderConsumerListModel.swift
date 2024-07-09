//
//  GXOrderConsumerListModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/9.
//

import UIKit
import HandyJSON

class GXOrderConsumerListData: HandyJSON {
    var total: Int = 0
    var rows: [GXChargingOrderDetailData] = []
    
    required init() {}
}

class GXOrderConsumerListModel: GXBaseModel {
    var data: GXOrderConsumerListData?
}
