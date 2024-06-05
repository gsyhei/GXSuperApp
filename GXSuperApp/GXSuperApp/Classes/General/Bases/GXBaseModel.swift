//
//  GXBaseModel.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit
import HandyJSON

class GXBaseModel: HandyJSON {
    var code: Int = -1
    var message: String = ""

    required init() {}
}

class GXBaseDataModel: GXBaseModel {
    var data: AnyObject?
}
