//
//  GXGetAboutUsModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import HandyJSON

class GXGetAboutUsData: NSObject, HandyJSON {
    var aboutPics: String = ""
    var aboutUs: String = ""
    var createTime: String = ""
    var deleted: Int = 0
    var id: Int = 0
    var updateTime: String = ""

    override required init() {}
}

class GXGetAboutUsModel: GXBaseModel {
    var data: GXGetAboutUsData?
}
