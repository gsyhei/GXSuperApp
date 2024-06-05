//
//  GXActivityEditBaseInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/15.
//

import UIKit
import HandyJSON

class GXActivityEditBaseInfoData: NSObject, HandyJSON {
    var activityId: Int?
    var activityMode: Int?
    var activityName: String?
    var activityTickets: [GXActivityticketsItem]?
    var activityTypeId: Int?
    var address: String?
    var cityName: String?
    var addressDesc: String?
    var confirmFlag: Int?
    var endDate: String?
    var endTime: String?
    var joinNum: String?
    var latitude: Double?
    var limitJoinNum: Int?
    var limitVip: Int?
    var longitude: Double?
    var startDate: String?
    var startTime: String?
    var signBeginDate: String?
    var signEndDate: String?

    override required init() {}
}
