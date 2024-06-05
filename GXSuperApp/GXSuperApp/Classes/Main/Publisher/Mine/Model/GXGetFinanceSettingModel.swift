//
//  GXGetFinanceSettingModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/15.
//

import UIKit
import HandyJSON

class GXGetFinanceSettingData: NSObject, HandyJSON {
    var createTime: String = ""
    var id: Int = 0
    var maxWithdrawalFee: Float = 0
    var minWithdrawalFee: Float = 0
    var platformDivisionRate: Int = 0
    var updateTime: String = ""
    var withdrawalFeeRate: Float = 0

    override required init() {}
}

class GXGetFinanceSettingModel: GXBaseModel {
    var data: GXGetFinanceSettingData?
}
