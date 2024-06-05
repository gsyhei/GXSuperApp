//
//  GXActivityMapInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/16.
//

import UIKit
import HandyJSON

class GXActivityMapInfoData: NSObject, HandyJSON {
    var mapDesc: String = ""
    var mapPics: String = ""

    override required init() {}
}

class GXActivityMapInfoModel: GXBaseModel {
    var data: GXActivityMapInfoData?
}
