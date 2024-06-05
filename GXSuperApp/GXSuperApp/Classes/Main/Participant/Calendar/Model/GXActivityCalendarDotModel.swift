//
//  GXActivityCalendarDotModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/20.
//

import UIKit
import HandyJSON

class GXActivityCalendarDotData: NSObject, HandyJSON {
    var date: String = ""
    var num: Int = 0

    override required init() {}
}

class GXActivityCalendarDotModel: GXBaseModel {
    var data: [GXActivityCalendarDotData] = []
}
