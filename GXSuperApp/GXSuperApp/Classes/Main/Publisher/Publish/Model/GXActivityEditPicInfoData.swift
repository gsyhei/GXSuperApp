//
//  GXActivityEditPicInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/15.
//

import UIKit
import HandyJSON

class GXActivityEditPicInfoData: NSObject, HandyJSON {
    var activityId: Int?
    var activityDesc: String?
    var listPics: String?
    var topPics: String?

    override required init() {}
}
