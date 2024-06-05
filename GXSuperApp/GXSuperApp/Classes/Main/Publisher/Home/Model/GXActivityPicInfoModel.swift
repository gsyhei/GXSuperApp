//
//  GXActivityPicInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/13.
//

import UIKit
import HandyJSON

class GXActivityPicInfoData: NSObject, HandyJSON {
    var activityDesc: String = ""
    var listPics: String = ""
    var topPics: String = ""

    override required init() {}
}

class GXActivityPicInfoModel: GXBaseModel {
    var data: GXActivityPicInfoData?
}
