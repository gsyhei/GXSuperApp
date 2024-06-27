//
//  GXConnectorConsumerListModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/27.
//

import UIKit
import HandyJSON

class GXConnectorConsumerRowsItem: NSObject, HandyJSON {
    var qrcode: String = ""
    var status: String = ""
    var pointId: Int = 0
    var currentType: String = ""
    var connectorId: Int = 0
    var pointIdStr: String = ""
    var maxPower: Int = 0
    var connectorName: String = ""
    var idleFlag: String = ""
    var soc: Int = 0
    var connectorIdStr: String = ""

    override required init() {}
}

class GXConnectorConsumerListData: NSObject, HandyJSON {
    var total: Int = 0
    var rows = [GXConnectorConsumerRowsItem]()

    override required init() {}
}

class GXConnectorConsumerListModel: GXBaseModel {
    var data: GXConnectorConsumerListData?
}
