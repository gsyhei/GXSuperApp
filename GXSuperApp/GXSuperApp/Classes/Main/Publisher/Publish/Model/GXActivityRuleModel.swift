//
//  GXActivityRuleModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import HandyJSON

class GXActivityRuleData: NSObject, HandyJSON {
    var createTime: String = ""
    var id: Int = 0
    var protocolContent: String = ""
    var protocolType: Int = 0
    var updateTime: String = ""

    override required init() {}
}

class GXActivityRuleModel: GXBaseModel {
    var data: GXActivityRuleData?
}
