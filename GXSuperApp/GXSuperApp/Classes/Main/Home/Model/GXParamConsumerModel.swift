//
//  GXHomeParamConsumerModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/26.
//

import UIKit
import HandyJSON

class GXParamConsumerData: NSObject, HandyJSON {
    var states = [String]()
    var occupyStartTime: Int = 0
    var occupyMax: String = ""
    var memberReduction: String = ""
    var memberFee: String = ""
    var memberFeeAutoRenew: String = ""
    var queryDistance: CGFloat = 0
    var memberDescription: String = ""

    override required init() {}
}

class GXParamConsumerModel: GXBaseModel {
    var data: GXParamConsumerData?
}
