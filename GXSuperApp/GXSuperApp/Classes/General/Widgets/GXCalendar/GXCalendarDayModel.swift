//
//  GXCalendarDayModel.swift
//  GXCalendarSample
//
//  Created by Gin on 2022/4/15.
//

import Foundation

public class GXCalendarDayModel: NSObject {
    public var date: Date
    public var isCurrentMonthOut: Bool
    public var canNotSelect: Bool = false

    public lazy var isToday: Bool = {
        return Calendar.current.isDate(self.date, inSameDayAs: GXServiceManager.shared.systemDate)
    }()

    public lazy var components: DateComponents = {
        return GXCalendar.gx_dateComponents(date: self.date)
    }()
    
    public lazy var chComponents: DateComponents = {
        return GXCalendar.gx_chineseDateComponents(date: self.date)
    }()

    public lazy var dateString: String = {
        return self.date.string(format: "yyyyMMdd")
    }()

    required init(date: Date, isCurrentMonthOut: Bool) {
        self.date = date
        self.isCurrentMonthOut = isCurrentMonthOut
    }

}

public class GXCalendarMonthModel: NSObject {
    public var monthDate: Date
    public var dayList: [GXCalendarDayModel] = []

    required init(monthDate: Date) {
        self.monthDate = monthDate
    }
}
