//
//  GXWalletConsumerBalanceModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/9.
//

import UIKit
import HandyJSON

class GXWalletConsumerBalanceData: HandyJSON {
    var available: CGFloat = 0
    
    required init() {}
}

class GXWalletConsumerBalanceModel: GXBaseModel {
    var data: GXWalletConsumerBalanceData?
}
