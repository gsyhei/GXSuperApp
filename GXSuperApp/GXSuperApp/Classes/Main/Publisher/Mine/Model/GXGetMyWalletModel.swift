//
//  GXGetMyWalletModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/12.
//

import UIKit
import HandyJSON

class GXFundjoursItem: NSObject, HandyJSON {
    var businessFlag: Int = 0
    var createTime: String = ""
    var entrustBalance: Float = 0
    var fee: Float = 0
    var fundAccount: Int = 0
    var id: Int = 0
    var orderSn: String = ""
    var orginalBalance: Float = 0
    var processResult: Bool?
    var remark: String = ""
    var transferNo: String = ""
    var updateTime: String = ""
    var userId: Int = 0
    var withdrawId: Int = 0

    override required init() {}
}

class GXFundjoursModel: NSObject, HandyJSON {
    var list = [GXFundjoursItem]()
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXGetMyWalletData: NSObject, HandyJSON {
    var enableBalance: Float = 0
    var frozenBalance: Float = 0
    var fundJours: GXFundjoursModel?

    override required init() {}
}

class GXGetMyWalletModel: GXBaseModel {
    var data: GXGetMyWalletData?
}
