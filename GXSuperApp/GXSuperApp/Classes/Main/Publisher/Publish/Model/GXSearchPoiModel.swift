//
//  GXSearchPoiModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/3/5.
//

import UIKit
import HandyJSON

/// 搜索请求模型
class GXSearchPostStrModel: NSObject, HandyJSON {
    var keyWord: String?
    var specify: String?
    var level: Int = 18
    var mapBound: String = "-180,-90,180,90"
    var queryType: Int = 1
    var start: Int = 0
    var count: Int = 20
    var show: Int = 2

    override required init() {}
}

class GXPrioritycitysModel: NSObject, HandyJSON {
    var adminName: String = ""
    var ename: String = ""
    var count: String = ""
    var adminCode: String = ""
    var lonlat: String = ""
    var isleaf: Bool?

    override required init() {}
}

class GXStatisticsModel: NSObject, HandyJSON {
    var adminCount: Int = 0
    var keyword: String = ""
    var allAdmins: [GXPrioritycitysModel] = []
    var priorityCitys: [GXPrioritycitysModel] = []
    
    override required init() {}
}

class GXSearchPoiModel: NSObject, HandyJSON {
    var resultType: Int = 0
    var count: Int = 0
    var keyWord: String = ""
    var status: GXStatusModel?
    var statistics: GXStatisticsModel?
    var pois: [GXPoisModel] = []
    var prompt: [GXPromptModel] = []
    
    override required init() {}
}

class GXPoisModel: NSObject, HandyJSON {
    var address: String = ""
    var phone: String = ""
    var poiType: String = ""
    var name: String = ""
    var source: String = ""
    var hotPointID: String = ""
    var lonlat: String = ""
    var province: String = ""
    var city: String = ""
    var county: String = ""

    override required init() {}
}

class GXAdminsModel: NSObject, HandyJSON {
    var adminName: String = ""
    var adminCode: Int = 0

    override required init() {}
}

class GXPromptModel: NSObject, HandyJSON {
    var type: Int = 0
    var admins: [GXAdminsModel] = []

    override required init() {}
}

class GXStatusModel: NSObject, HandyJSON {
    var cndesc: String = ""
    var infocode: Int = 0

    override required init() {}
}
