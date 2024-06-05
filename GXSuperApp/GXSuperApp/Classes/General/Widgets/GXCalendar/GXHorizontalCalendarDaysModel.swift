//
//  GXHorizontalCalendarDaysModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit

class GXHorizontalCalendarDaysModel: NSObject {
    public var todayDate: Date
    public var selectedDates: [Date] = []
    public var todayIndex: Int = 0
    public var todaySection: Int = 0

    public var minSelectDate: Date?
    public var maxSelectDate: Date?

    /// 当前页索引
    public var currentPageIndex: Int = 0

    public lazy var components: DateComponents = {
        return GXCalendar.gx_dateComponents(date: self.todayDate)
    }()

    public var dayList: [GXCalendarDayModel] = []
    public var monthDayList: [GXCalendarMonthModel] = []
    public var dotsDict: Dictionary<String, Set<String>> = [:]

    public init(date: Date) {
        self.todayDate = date
    }
    
    convenience init(date: Date, minSelectDate: Date?, maxSelectDate: Date?) {
        self.init(date: date)
        self.stupCalendar(minSelectDate: minSelectDate, maxSelectDate: maxSelectDate)
    }

    convenience init(date: Date, isPublish: Bool) {
        self.init(date: date)
        if isPublish {
            self.stupCalendar(minSelectDate: nil, maxSelectDate: nil)
        } else {
            self.stupCalendar(minSelectDate: self.todayDate, maxSelectDate: nil)
        }
    }

    func stupCalendar(minSelectDate: Date?, maxSelectDate: Date?) {
        var beginDate: Date, endDate: Date
        if let letMinSelectDate = minSelectDate {
            beginDate = letMinSelectDate
        } else {
            beginDate = Calendar.current.date(byAdding: .year, value: -3, to: self.todayDate) ?? Date()
        }
        if let letMaxSelectDate = maxSelectDate {
            endDate = letMaxSelectDate
        } else {
            endDate = Calendar.current.date(byAdding: .init(year: 2, day: -1), to: self.todayDate) ?? Date()
        }
        beginDate = Calendar.current.startOfDay(for: beginDate)
        endDate = Calendar.current.startOfDay(for: endDate)
        
        let disComponents = Calendar.current.dateComponents([.month], from: beginDate, to: endDate)
        let differenceMonth = (disComponents.month ?? 0) + 1
        for monthIndex in 0...differenceMonth {
            guard let monthDate = Calendar.current.date(byAdding: .month, value: monthIndex, to: beginDate) else { continue }
            var beginDateComponents = GXCalendar.gx_dateComponents(date: monthDate)
            beginDateComponents.day = 1
            guard let monthFirstDate = Calendar.current.date(from: beginDateComponents) else { continue }
            // 添加monthDate月的日期
            let numberOfDays = GXCalendar.gx_numberOfDaysInMonth(date: monthFirstDate)
            let monthModel = GXCalendarMonthModel(monthDate: monthFirstDate)
            for dayIndex in 0..<numberOfDays {
                guard let reDate = Calendar.current.date(byAdding: .day, value: dayIndex, to: monthFirstDate) else { continue }
                let model = GXCalendarDayModel(date: reDate, isCurrentMonthOut: false)
                if model.isToday {
                    self.todaySection = self.monthDayList.count
                    self.todayIndex = self.dayList.count
                }
                if model.date < beginDate || model.date > endDate {
                    model.canNotSelect = true
                } else {
                    self.dayList.append(model)
                }
                monthModel.dayList.append(model)
            }
            // 添加monthDate第一天之前空格的日期
            if let firstDay = monthModel.dayList.first {
                let firstDayWeek = firstDay.components.weekday ?? 1
                if firstDayWeek > 1 {
                    for index in (1..<firstDayWeek) {
                        let reDate = Calendar.current.date(byAdding: .day, value: -index, to: firstDay.date)
                        if let letReDate = reDate {
                            let model = GXCalendarDayModel(date: letReDate, isCurrentMonthOut: true)
                            monthModel.dayList.insert(model, at: 0)
                        }
                    }
                }
            }
            self.monthDayList.append(monthModel)
        }
    }

}
