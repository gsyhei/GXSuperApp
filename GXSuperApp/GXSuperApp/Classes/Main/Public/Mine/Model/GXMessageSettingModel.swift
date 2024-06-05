//
//  GXMessageSettingModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import HandyJSON

class GXMessageSettingData: NSObject, HandyJSON {
    var bonusMessage: Int = 0
    var chatConsultateMessage: Int = 0
    var chatGroupMessage: Int = 0
    var questionaireMessage: Int = 0
    var reportMessage: Int = 0
    var createTime: String = ""
    var id: Int = 0
    var targetType: Int = 0
    var updateTime: String = ""
    var userId: Int = 0

    override required init() {}
}

class GXMessageSettingModel: GXBaseModel {
    var data: GXMessageSettingData?
}
