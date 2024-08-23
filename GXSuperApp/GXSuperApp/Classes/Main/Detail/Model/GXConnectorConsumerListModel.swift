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
