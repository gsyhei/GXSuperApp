//
//  GXBaseModel.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit
import HandyJSON

class GXBaseModel: NSObject, HandyJSON {
    var success: Bool = false
    var code: Int = -1
    var msg: String = ""

    required override init() {}
}

class GXBaseDataModel: GXBaseModel {
    var data: AnyObject?
}
