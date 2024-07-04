//
//  GXFavoriteConsumerSaveModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/4.
//

import UIKit
import HandyJSON

class GXFavoriteConsumerSaveData: NSObject, HandyJSON {
    var favoriteFlag: Bool = false

    override required init() {}
}

class GXFavoriteConsumerSaveModel: GXBaseModel {
    var data: GXFavoriteConsumerSaveData?
}
