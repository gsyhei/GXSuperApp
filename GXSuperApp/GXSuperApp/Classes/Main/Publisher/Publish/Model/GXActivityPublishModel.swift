//
//  GXActivityPublishModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/4.
//

import UIKit
import HandyJSON

class GXActivityticketsItem: NSObject, HandyJSON {
    var activityId: Int?
    var beginDate: String?
    var createTime: String?
    var deadlineDate: String?
    var id: Int?
    var normalPrice: String?
    var ticketType: Int?
    var title: String?
    var updateTime: String?
    var vipPrice: String?

    override required init() {}

    func isEditCommit() -> Bool {
        if self.normalPrice?.count ?? 0 == 0 {
            return false
        }
        if self.beginDate?.count ?? 0 == 0 {
            return false
        }
        if self.deadlineDate?.count ?? 0 == 0 {
            return false
        }
        return true
    }
}

class GXActivityPublishData: NSObject, HandyJSON {
    var activityDesc: String?
    var activityMode: Int?
    var activityName: String?
    var activityOrder: Int?
    var activityStatus: Int?
    var activityTickets: [GXActivityticketsItem]?
    var activityTypeId: Int?
    var address: String?
    var addressDesc: String?
    var cityName: String?
    var approveTime: String?
    var createTime: String?
    var creatorId: Int?
    var deleted: Int?
    var dressCode: String?
    var endDate: Int?
    var endTime: String?
    var activityId: Int?
    var joinNum: Int?
    var latitude: Double?
    var limitJoinNum: Int?
    var limitVip: Int?
    var listPics: String?
    var longitude: Double?
    var mapDesc: String?
    var mapPics: String?
    var normalBenefits: String?
    var rejectReason: String?
    var shelfStatus: Int?
    var startDate: Int?
    var startTime: String?
    var topPics: String?
    var updateTime: String?
    var vipBenefits: String?
    var signBeginDate: String?
    var signEndDate: String?

    override required init() {}
}

class GXActivityPublishModel: GXBaseModel {
    var data: GXActivityPublishData?
}
