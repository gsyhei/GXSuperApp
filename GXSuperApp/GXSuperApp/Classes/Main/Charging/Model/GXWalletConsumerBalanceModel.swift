//
//  GXWalletConsumerBalanceModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/9.
//

import UIKit
import HandyJSON

class GXWalletConsumerBalanceData: HandyJSON {
    var available: Float = 0
    /// 付款方式；SETUP_INTENT：预授权，BALANCE：余额
    var paymentMethod: String = ""
    var paymentMethodId: String = ""
    
    required init() {}
}

class GXWalletConsumerBalanceModel: GXBaseModel {
    var data: GXWalletConsumerBalanceData?
}
