//
//  GXGetRealNameModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit
import HandyJSON

class GXGetRealNameData: NSObject, HandyJSON {
    var idNo: String = ""
    var realName: String = ""

    override required init() {}
}

class GXGetRealNameModel: GXBaseModel {
    var data: GXGetRealNameData?
}
