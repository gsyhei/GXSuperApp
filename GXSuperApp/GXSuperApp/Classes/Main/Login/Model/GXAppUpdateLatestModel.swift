//
//  GXAppUpdateLatestModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/26.
//

import UIKit
import HandyJSON

class GXAppUpdateLatestData: NSObject, HandyJSON {
    var id: Int = 0
    var type: String = ""
    var version: String = ""
    var releaseDate: String = ""
    var downloadUrl: String = ""
    var forceFlag: String = ""
    
    required override init() {}
}

class GXAppUpdateLatestModel: GXBaseModel {
    var data: GXAppUpdateLatestData?
}
