//
//  GXParticipantCalendarViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/26.
//

import UIKit
import XCGLogger

class GXParticipantCalendarViewModel: GXBaseViewModel {
    // MARK: - 入参

    /// 日历
    lazy var calendar: GXHorizontalCalendarDaysModel = {
        return GXHorizontalCalendarDaysModel(date: GXServiceManager.shared.systemDate, isPublish: false)
    }()
    /// 活动类型列表
    var activityTypeIds: [String] = []
    /// 活动价格 1-100以内 2-100~300 3-300~500 4-500以上
    var priceType: Int?
    /// 排序 1-热度 2-最近更新 3-活动开始时间 4-距离
    var sortBy: Int?
    /// 分页
    var pageNum: Int = 1

    // MARK: - request

    /// 活动列表
    var list: [GXCalendarActivityItem] = []

    /// 日历活动
    func requestCalendarActivity(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["city"] = GXUserManager.shared.city
        if calendar.selectedDates.count == 2 {
            var beginDate: Date, endDate: Date
            if calendar.selectedDates[0] > calendar.selectedDates[1] {
                beginDate = calendar.selectedDates[1]; endDate = calendar.selectedDates[0]
            } else {
                beginDate = calendar.selectedDates[0]; endDate = calendar.selectedDates[1]
            }
            params["startDate"] = beginDate.string(format: "yyyyMMdd")
            params["endDate"] = endDate.string(format: "yyyyMMdd")
            self.requestGetCalendarDot(start: beginDate, end: endDate) {
                XCGLogger.info("切换日历小红点成功")
            } failure: { error in
                XCGLogger.info("切换日历小红点失败：\(error.localizedDescription)")
            }
        } else if calendar.selectedDates.count == 1 {
            let date = calendar.selectedDates[0]
            params["startDate"] = date.string(format: "yyyyMMdd")
            params["endDate"] = date.string(format: "yyyyMMdd")
            self.requestGetCalendarDot(start: date, end: date) {
                XCGLogger.info("切换日历小红点成功")
            } failure: { error in
                XCGLogger.info("切换日历小红点失败：\(error.localizedDescription)")
            }
        }
        if self.activityTypeIds.count > 0 {
            params["activityTypeIds"] = self.activityTypeIds.joined(separator: ",")
        }
        if let letPriceType = self.priceType {
            params["priceType"] = letPriceType
        }
        if let letSortBy = self.sortBy {
            params["sortBy"] = letSortBy
        }
        if let location = GXUserManager.shared.location {
            params["latitude"] = location.latitude
            params["longitude"] = location.longitude
        }
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_CActivity_CalendarActivity, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXCalendarActivityModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            guard let data = model.data else {
                success(false); return
            }
            if refresh { self.list.removeAll() }
            self.list.append(contentsOf: data.list)
            self.pageNum = data.pageNum + 1
            success(data.pageNum >= data.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 日历小红点
    func requestGetCalendarDot(start: Date? = nil, end: Date? = nil, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["city"] = GXUserManager.shared.city

        var startDate: Date?
        if let start = start {
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: start)
        } else {
            startDate = self.calendar.todayDate
        }
        var endDate: Date?
        if let end = end {
            endDate = Calendar.current.date(byAdding: .month, value: 1, to: end)
        } else {
            endDate = Calendar.current.date(byAdding: .month, value: 3, to: self.calendar.todayDate)
        }
        if let startDate = startDate {
            let startDateStr = startDate.string(format: "yyyyMMdd")
            params["startDate"] = startDateStr
        }
        if let endDate = endDate {
            let endDateStr = endDate.string(format: "yyyyMMdd")
            params["endDate"] = endDateStr
        }
        let api = GXApi.normalApi(Api_CActivity_Calendar, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityCalendarDotModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.updateCalendarDot(model: model)
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 更新日历小红点
    func updateCalendarDot(model: GXActivityCalendarDotModel) {
        var dotsDict = self.calendar.dotsDict
        for dotItem in model.data {
            guard dotItem.num > 0 else { continue }
            guard dotItem.date.count == 8 else { continue }

            let yyyyMMKey = dotItem.date[0, 6]
            if var list = dotsDict[yyyyMMKey] {
                list.update(with: dotItem.date)
                dotsDict.updateValue(list, forKey: yyyyMMKey)
            }
            else {
                var list: Set<String> = []
                list.update(with: dotItem.date)
                dotsDict.updateValue(list, forKey: yyyyMMKey)
            }
        }
        self.calendar.dotsDict = dotsDict
    }

}
