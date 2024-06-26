//
//  GXHomeParamConsumerModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/26.
//

import UIKit
import HandyJSON

class GXParamConsumerData: NSObject, HandyJSON {
    var forceFlag: String = ""
    var id: Int = 0
    var releaseDate: String = ""
    var type: String = ""
    var downloadUrl: String = ""
    var version: String = ""
    var queryDistance: Double = 0 //千米

    override required init() {}
}

class GXParamConsumerModel: GXBaseModel {
    var data: GXParamConsumerData?
}
