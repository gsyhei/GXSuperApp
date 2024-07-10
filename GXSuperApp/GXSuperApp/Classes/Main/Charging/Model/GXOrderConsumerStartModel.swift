//
//  GXOrderConsumerStartEndModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import HandyJSON

class GXOrderConsumerStartData: HandyJSON {
    var id: Int = 0 //订单ID
    
    required init() {}
}

class GXOrderConsumerStartModel: GXBaseModel {
    var data: GXOrderConsumerStartData?
}
