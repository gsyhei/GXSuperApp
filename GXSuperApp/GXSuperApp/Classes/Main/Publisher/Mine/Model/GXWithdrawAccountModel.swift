//
//  GXWithdrawAccountModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/15.
//

import UIKit
import HandyJSON

class GXWithdrawAccountData: NSObject, HandyJSON {
    var alipayAccount: String = ""
    var createTime: String = ""
    var id: Int = 0
    var realName: String = ""
    var updateTime: String = ""
    var userId: Int = 0

    override required init() {}
}

class GXWithdrawAccountModel: GXBaseModel {
    var data: GXWithdrawAccountData?
}
