//
//  GXActivityFinanceInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit
import HandyJSON

class GXActivityfinancesListItem: NSObject, HandyJSON {
    var activityId: Int = 0
    var createTime: String = ""
    var creatorId: Int = 0
    var deleted: Int = 0
    var id: Int = 0
    var materialName: String = ""
    var quantity: Int = 0
    var totalPrice: Float = 0
    var unitPrice: Float = 0
    var updateTime: String = ""

    override required init() {}
}

class GXActivityfinancesModel: NSObject, HandyJSON {
    var list: [GXActivityfinancesListItem] = []
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXActivityFinanceInfoData: NSObject, HandyJSON {
    var activityFinances: GXActivityfinancesModel?
    var materialBalance: Float = 0
    var profitBalance: Float = 0
    var signBalance: Float = 0

    override required init() {}
}

class GXActivityFinanceInfoModel: GXBaseModel {
    var data: GXActivityFinanceInfoData?
}
