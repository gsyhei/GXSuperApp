//
//  GXCalendarActivityModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/26.
//

import UIKit

import HandyJSON

import HandyJSON

class GXCalendarActivityItem: NSObject, HandyJSON {
    var activityDesc: String = ""
    var activityMode: Int = 0
    var activityName: String = ""
    var activityOrder: Int = 0
    var activityStatus: Int = 0
    var activityTicket: GXActivityticketlistItem?
    var activityTickets: [GXActivityticketlistItem] = []
    var activityTypeId: Int = 0
    var activityTypeName: String = ""
    var address: String = ""
    var cityName: String = ""
    var addressDesc: String = ""
    var approveTime: String = ""
    var avatarPic: String = ""
    var createTime: String = ""
    var creatorId: Int = 0
    var deleted: Int = 0
    var dressCode: String = ""
    var endDate: String = ""
    var endTime: String = ""
    var signBeginDate: String = ""
    var signEndDate: String = ""
    var favoriteNum: Int = 0
    var id: Int = 0
    var joinNum: Int = 0
    var latitude: Int = 0
    var limitJoinNum: Int = 0
    var limitVip: Int = 0
    var listPics: String = ""
    var longitude: Int = 0
    var mapDesc: String = ""
    var mapPics: String = ""
    var nickName: String = ""
    var normalBenefits: String = ""
    var phone: String = ""
    var price: Int = 0
    var rejectReason: String = ""
    var setTop: Int = 0
    var shelfStatus: Int = 0
    var signedNum: Int = 0
    var startDate: String = ""
    var startTime: String = ""
    var topPics: String = ""
    var updateTime: String = ""
    var userExpertTitles = [Any]()
    var vipBenefits: String = ""

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
    
    func getSignUpModel() -> GXMySignModel {
        let signUpModel = GXMySignModel()
        let systemDate = GXServiceManager.shared.systemDate
        if self.activityMode == 2 {
            //卖票模式
            for ticket in self.activityTickets {
                guard let beginDate = Date.date(dateString: ticket.beginDate, format: "yyyyMMdd") else {
                    signUpModel.canDateSignType = 0
                    signUpModel.ticket = ticket
                    break
                }
                guard let endDate = Date.date(dateString: ticket.deadlineDate, format: "yyyyMMdd") else {
                    signUpModel.canDateSignType = 2
                    signUpModel.ticket = ticket
                    break
                }
                if systemDate < beginDate {
                    if ticket.ticketType == 2 { // 早鸟
                        signUpModel.canDateSignType = 0
                        signUpModel.ticket = ticket
                    }
                    else if signUpModel.canDateSignType == -1 {
                        signUpModel.canDateSignType = 0
                        signUpModel.ticket = ticket
                    }
                }
                else if (Calendar.current.dateComponents([.day], from: endDate, to: systemDate).day ?? 0) > 0 {
                    if ticket.ticketType == 1 { // 标准价
                        signUpModel.canDateSignType = 2
                        signUpModel.ticket = ticket
                    }
                }
                else {
                    signUpModel.ticket = ticket
                    signUpModel.canDateSignType = 1
                }
            }
        }
        else {
            //报名模式
            guard let beginDate = Date.date(dateString: self.signBeginDate, format: "yyyyMMdd") else {
                signUpModel.canDateSignType = 0
                return signUpModel
            }
            guard let endDate = Date.date(dateString: self.signEndDate, format: "yyyyMMdd") else {
                signUpModel.canDateSignType = 2
                return signUpModel
            }
            if systemDate < beginDate {
                signUpModel.canDateSignType = 0
            }
            else if Calendar.current.dateComponents([.day], from: endDate, to: systemDate).day ?? 0 > 0 {
                signUpModel.canDateSignType = 2
            }
            else {
                signUpModel.canDateSignType = 1
            }
        }
        return signUpModel
    }
}

class GXCalendarActivityData: NSObject, HandyJSON {
    var list: [GXCalendarActivityItem] = []
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXCalendarActivityModel: GXBaseModel {
    var data: GXCalendarActivityData?
}
