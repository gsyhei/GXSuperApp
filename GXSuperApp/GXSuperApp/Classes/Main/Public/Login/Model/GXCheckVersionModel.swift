//
//  GXCheckVersionModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/26.
//

import UIKit
import HandyJSON

class GXCheckVersionData: NSObject, HandyJSON {
    var apkUrl: String = ""
    var appType: Int = 0
    var createTime: String = ""
    var deleted: Int = 0
    var forceUpdate: Bool = false
    var hasNewVersion: Bool = false
    var id: Int = 0
    var updateTime: String = ""
    var versionContent: String = ""
    var versionNo: String = ""
    var versionTitle: String = ""

    override required init() {}
}

class GXCheckVersionModel: GXBaseModel {
    var data: GXCheckVersionData?
}
