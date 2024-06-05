//
//  GXGetWithdrawDetailModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit
import HandyJSON

class GXGetWithdrawDetailData: NSObject, HandyJSON {
    var alipayAccount: String = ""
    var applyStatus: Int = 0
    var createTime: String = ""
    var enableBalance: String = ""
    var entrustBalance: String = ""
    var id: Int = 0
    var nickName: String = ""
    var phone: String = ""
    var processId: Int = 0
    var processTime: String = ""
    var processUser: String = ""
    var realBalance: Int = 0
    var realName: String = ""
    var rejectReason: String = ""
    var transferNo: String = ""
    var updateTime: String = ""
    var userId: Int = 0
    var withdrawalFee: String = ""

    override required init() {}
}

class GXGetWithdrawDetailModel: GXBaseModel {
    var data: GXGetWithdrawDetailData?
}
