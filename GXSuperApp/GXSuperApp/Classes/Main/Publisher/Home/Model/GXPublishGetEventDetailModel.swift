//
//  GXPublishEventStepData.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/18.
//

import UIKit
import HandyJSON

class GXPublishEventsignsData: NSObject, HandyJSON {
    var activityId: Int?
    var createTime: String?
    var eventId: Int?
    var eventReward: String?
    var id: Int?
    var operatorId: Int?
    var operatorTime: String?
    var signTime: String?
    var updateTime: String?
    var userId: Int?
    var avatarPic: String?
    var nickName: String?
    var pushMessageFlag: Bool?

    override required init() {}
}

class GXPublishEventStepData: NSObject, HandyJSON {
    var activityId: Int?
    var createTime: String?
    var address: String?
    var beginDate: String?
    var endDate: String?
    var beginTime: String?
    var endTime: String?
    var eventDesc: String?
    var eventPicsDesc: String?
    var eventMaps: String?
    var eventPics: String?
    var eventSigns: [GXPublishEventsignsData]?
    var eventStatus: Int?
    var eventTitle: String?
    var id: Int?
    var latitude: Int?
    var longitude: Int?
    var signBeginDate: String?
    var signEndDate: String?
    var signBeginTime: String?
    var signEndTime: String?
    var updateTime: String?
    var signEventFlag: Int?

    override required init() {}

    func startToEndDateString() -> String {
        guard let startDate = Date.date(dateString: self.beginDate ?? "", format: "yyyyMMdd") else {
            return ""
        }
        guard let endDate = Date.date(dateString: self.endDate ?? "", format: "yyyyMMdd") else {
            return ""
        }
        let startComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
        let endComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
        var dateString = ""
        if startComponents.year != endComponents.year {
            var startDateStr = startDate.string(format: "yyyy年M月d日")
            if let time = self.beginTime, time.count > 0 {
                startDateStr += (" " + time)
            }
            var endDateStr = endDate.string(format: "yyyy年M月d日")
            if let time = self.endTime, time.count > 0 {
                endDateStr += (" " + time)
            }
            dateString = startDateStr + " 至 " + endDateStr
        }
        else if startComponents.month != endComponents.month {
            var startDateStr = startDate.string(format: "yyyy年M月d日")
            if let time = self.beginTime, time.count > 0 {
                startDateStr += (" " + time)
            }
            var endDateStr = endDate.string(format: "M月d日")
            if let time = self.endTime, time.count > 0 {
                endDateStr += (" " + time)
            }
            dateString = startDateStr + " 至 " + endDateStr
        }
        else if startComponents.day != endComponents.day {
            var startDateStr = startDate.string(format: "yyyy年M月d日")
            if let time = self.beginTime, time.count > 0 {
                startDateStr += (" " + time)
            }
            var endDateStr = endDate.string(format: "M月d日")
            if let time = self.endTime, time.count > 0 {
                endDateStr += (" " + time)
            }
            dateString = startDateStr + " 至 " + endDateStr
        }
        else {
            var startDateStr = startDate.string(format: "yyyy年M月d日")
            if let time = self.beginTime, time.count > 0 {
                startDateStr += (" " + time)
            }
            if let time = self.endTime, time.count > 0 {
                startDateStr += (" 至 " + time)
            }
            dateString = startDateStr
        }
        return dateString
    }
}

class GXPublishGetEventDetailModel: GXBaseModel {
    var data: GXPublishEventStepData?
}
