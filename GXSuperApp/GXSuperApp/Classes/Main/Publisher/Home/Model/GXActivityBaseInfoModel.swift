//
//  GXActivityBaseInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/11.
//

import UIKit
import HandyJSON

class GXActivityBaseInfoData: NSObject, HandyJSON {
    var roleType: String = "" //活动角色类型 1-发布者 2-管理员 3-核销票 4-客服,多个角色逗号隔开
    var activityMode: Int = 1 // (1-免费报名模式 2-卖票模式)
    var activityName: String = ""
    var activityStatus: Int = 0
    var activityTickets: [GXActivityticketlistItem] = []
    var activityTicketList: [GXActivityticketlistItem] = []
    var tickets: [GXActivityticketlistItem] {
        if self.activityTickets.count > 0 {
            return self.activityTickets
        }
        if self.activityTicketList.count > 0 {
            return self.activityTicketList
        }
        return []
    }
    var activityTypeId: Int = 0
    var activityTypeName: String = ""
    var address: String = ""
    var cityName: String = ""
    var addressDesc: String = ""
    var approveTime: String = ""
    var avatarPic: String = ""
    var creatorId: String = ""
    var createTime: String = ""
    var endDate: String = ""
    var endTime: String = ""
    var favoriteNum: Int = 0
    var favoriteFlag: Int = 0
    var id: Int = 0
    var joinNum: String = ""
    var latitude: Double = 0
    var limitJoinNum: Int = 0
    var limitVip: Int = 0
    var listPics: String = ""
    var longitude: Double = 0
    var nickName: String = ""
    var rejectReason: String = ""
    var shelfStatus: Int = 0
    var signedNum: Int = 0
    var signFlag: Int = 0
    var signBeginDate: String = ""
    var signEndDate: String = ""
    var startDate: String = ""
    var startTime: String = ""
    var vipFlag: Bool = false
    var realnameFlag: Bool = false
    var expertFlag: Bool = false
    var officialFlag: Bool = false
    var orgAccreditationFlag: Bool = false
    var userExpertTitles: [String] = []

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
            for ticket in self.tickets {
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

class GXActivityBaseInfoModel: GXBaseModel {
    var data: GXActivityBaseInfoData?
}

class GXMySignModel: NSObject {
    /// 当前日期时间是否可以报名
    var canDateSignUp: Bool {
        return (self.canDateSignType == 1)
    }
    /// 当前日期时间与报名日期相比（0未到报名时间，1可以报名，2报名时间已过）
    var canDateSignType: Int = -1
    /// 适用票
    var ticket: GXActivityticketlistItem?
}
