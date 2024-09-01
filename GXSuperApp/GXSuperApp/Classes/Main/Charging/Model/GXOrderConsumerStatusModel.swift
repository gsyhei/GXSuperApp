//
//  GXOrderConsumerStatusModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/31.
//

import UIKit
import HandyJSON

class GXOrderConsumerStatusData: NSObject, HandyJSON {
    //充电状态；STARTING：启动中，CHARGING：充电中，STOPPING：停止中，FINISHED：充电完成，START_FAILED：启动失败
    var status: String = ""
    //订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：已完成
    var orderStatus: String = ""

    override required init() {}
}

class GXOrderConsumerStatusModel: GXBaseModel {
    var data: GXOrderConsumerStatusData?
}
