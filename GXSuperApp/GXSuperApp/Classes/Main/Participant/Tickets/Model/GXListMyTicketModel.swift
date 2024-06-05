//
//  GXListMyTicketModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import UIKit
import HandyJSON

class GXListMyTicketItem: NSObject, HandyJSON {
    var activityId: Int = 0
    var activityName: String = ""
    var activitySignId: Int = 0
    var activityStatus: Int = 0
    var activityTypeName: String = ""
    var address: String = ""
    var cityName: String = ""
    var addressDesc: String = ""
    var createTime: String = ""
    var deleted: Int = 0
    var endDate: String = ""
    var endTime: String = ""
    var id: Int = 0
    var listPics: String = ""
    var orderId: Int = 0
    var startDate: String = ""
    var startTime: String = ""
    var ticketCode: String = ""
    var ticketStatus: Int = 0
    var updateTime: String = ""
    var userId: Int = 0
    var verifyTime: String = ""
    var verifyUserId: Int = 0

    override required init() {}
    
    func showCityName() -> String {
        if self.cityName.isEmpty {
            return self.address
        }
        else {
            return self.cityName + "丨" + self.addressDesc
        }
    }

    func showAddress() -> String {
        if self.cityName.isEmpty {
            return self.addressDesc
        }
        else {
            return self.address
        }
    }

    func startToEndDateString() -> String {
        guard let startDate = Date.date(dateString: self.startDate, format: "yyyyMMdd") else {
            return self.startDate + " ~ " + self.endDate
        }
        guard let endDate = Date.date(dateString: self.endDate, format: "yyyyMMdd") else {
            return self.startDate + " ~ " + self.endDate
        }
        let startComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
        let endComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
        var dateString = ""
        if startComponents.year != endComponents.year {
            let startDateStr = startDate.string(format: "yyyy年M月d日")
            let endDateStr = endDate.string(format: "yyyy年M月d日")
            dateString = startDateStr + " 至 " + endDateStr
        }
        else if startComponents.month != endComponents.month {
            let startDateStr = startDate.string(format: "yyyy年M月d日")
            let endDateStr = endDate.string(format: "M月d日")
            dateString = startDateStr + " 至 " + endDateStr
        }
        else if startComponents.day != endComponents.day {
            let startDateStr = startDate.string(format: "yyyy年M月d日")
            let endDateStr = endDate.string(format: "M月d日")
            dateString = startDateStr + " 至 " + endDateStr
        }
        else {
            let startDateStr = startDate.string(format: "yyyy年M月d日")
            dateString = startDateStr
        }
        if self.startTime.count > 0 && self.endTime.count > 0 {
            dateString = dateString + " " + self.startTime + "~" + self.endTime
        }
        return dateString
    }
}

class GXListMyTicketData: NSObject, HandyJSON {
    var list: [GXListMyTicketItem] = []
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXListMyTicketModel: GXBaseModel {
    var data: GXListMyTicketData?
}
