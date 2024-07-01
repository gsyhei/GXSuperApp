//
//  GXVehicleConsumerListModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/1.
//

import UIKit
import HandyJSON

class GXVehicleConsumerListItem: NSObject, HandyJSON {
    var id: Int = 0
    var state: String = ""
    var carNumber: String = ""

    override required init() {}
}

class GXVehicleConsumerListModel: GXBaseModel {
    var data: [GXVehicleConsumerListItem] = []
}
