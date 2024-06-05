//
//  GXActivityEventInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import HandyJSON

class GXActivityEventInfoData: NSObject, HandyJSON {
    var activityEvents: [GXPublishEventStepData] = []
    var finishedActivityEvents: [GXPublishEventStepData] = []
    var mapPics: String = ""

    override required init() {}
}

class GXActivityEventInfoModel: GXBaseModel {
    var data: GXActivityEventInfoData?
}
