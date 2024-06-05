//
//  GXPtHomeGetMusicStationsModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/6.
//

import UIKit
import HandyJSON

class GXPtHomeGetMusicStationsItem: NSObject, HandyJSON {
    var audioFile: String = ""
    var coverPic: String = ""
    var createTime: String = ""
    var deleted: Bool = false
    var id: Int = 0
    var showHomePage: Bool = false
    var sourceUrl: String = ""
    var subTitle: String = ""
    var title: String = ""
    var updateTime: String = ""

    override required init() {}
}

class GXPtHomeGetMusicStationsModel: GXBaseModel {
    var data: [GXPtHomeGetMusicStationsItem] = []
}
