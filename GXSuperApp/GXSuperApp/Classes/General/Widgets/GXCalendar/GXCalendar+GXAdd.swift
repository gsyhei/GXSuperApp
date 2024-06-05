//
//  GXCalendar+Private.swift
//  GXCalendarSample
//
//  Created by Gin on 2022/4/14.
//

import Foundation

public extension GXCalendar {
    // MARK: - Private

    private static var gx_zodiacs: [String] {
        return ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
    }
    
    private static var gx_heavenlystems: [String] {
        return ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    }
    
    private static var gx_earthlybranches: [String] {
        return ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    }
    
    private static var gx_month: [String] {
        return ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
    }
    
    private static var gx_day: [String] {
        return ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "廿十",
                "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    }
    
    private static var gx_week: [String] {
        return ["日", "一", "二", "三", "四", "五", "六"]
    }

    private static var gx_week1: [String] {
        return ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    }

    // MARK: - Public
    
    /// 根据日期获取DateComponents
    /// - Parameter date: 目标日期
    /// - Returns: DateComponents[.year, .month, .day, .weekOfMonth, .weekday]
    class func gx_dateComponents(date: Date) -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        
        return components
    }
    
    /// 根据日期获取农历DateComponents
    /// - Parameter date: 目标日期
    /// - Returns: DateComponents[.year, .month, .day]
    class func gx_chineseDateComponents(date: Date) -> DateComponents {
        let calendar = Calendar(identifier: .chinese)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        return components
    }
    
    /// 根据年月日获取日期
    /// - Parameters:
    ///   - year: 指定年
    ///   - month: 指定月
    ///   - day: 指定日
    /// - Returns: 指定年月日Date
    class func gx_date(year: Int = 1970, month: Int = 1, day: Int = 1) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = year
        components.month = month
        components.day = day
        guard let newDate = calendar.date(from: components) else {
            fatalError("传参year/month/day有误，获取日期错误！")
        }
        return  newDate
    }
    
    /// 根据日期获取当月天数
    /// - Parameter date: 日期
    /// - Returns: 当月天数Int
    class func gx_numberOfDaysInMonth(date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)
        
        return range?.count ?? 0
    }
    
    /// 根据农历年获取[生肖]
    /// - Parameter year: 年
    /// - Returns: 生肖String
    class func gx_chineseZodiac(year: Int) -> String {
        let zodiacindex: Int = (year - 1) % gx_zodiacs.count
        
        return gx_zodiacs[zodiacindex]
    }
    class func gx_chineseZodiac(components: DateComponents) -> String {
        let year: Int = components.year ?? 1
        
        return self.gx_chineseZodiac(year: year)
    }
    
    /// 根据农历年获取[天干地支]
    /// - Parameter year: 年
    /// - Returns: 天干地支String
    class func gx_chineseEra(year: Int) -> String {
        let hsIndex: Int = (year - 1) % gx_heavenlystems.count
        let heavenlystem: String = gx_heavenlystems[hsIndex]
        let ebIndex: Int = (year - 1) % gx_earthlybranches.count
        let earthlybranche: String = gx_earthlybranches[ebIndex]
        
        return heavenlystem + earthlybranche
    }
    class func gx_chineseEra(components: DateComponents) -> String {
        let year: Int = components.year ?? 1
        
        return self.gx_chineseEra(year: year)
    }
    
    /// 根据农历月日获取[农历日]
    /// - Parameter month: 月
    /// - Parameter day: 日
    /// - Returns: 农历日String
    class func gx_chineseDay(month: Int, day: Int) -> String {
        guard day > 1 else { return gx_month[month - 1] }

        return gx_day[day - 1]
    }
    class func gx_chineseDay(components: DateComponents) -> String {
        let day = components.day ?? 1
        let month = components.month ?? 1

        return self.gx_chineseDay(month: month, day: day)
    }
    
    /// 根据周索引获取周几
    /// - Parameter week: 周
    /// - Returns: 周几String
    class func gx_weekDay(week: Int) -> String {
        return gx_week[week - 1]
    }
    class func gx_week1Day(week: Int) -> String {
        return gx_week1[week - 1]
    }
    class func gx_weekDay(components: DateComponents, weekType: Int = 0) -> String {
        let week = components.weekday ?? 1
        if weekType == 1 {
            return self.gx_week1Day(week: week)
        } else {
            return self.gx_weekDay(week: week)
        }
    }
    
    /// 根据日期获取日期显示
    /// - Parameter day: 日期
    /// - Returns: 显示日期String
    class func gx_day(day: Int) -> String {
        return String(format: "%02d", day)
    }
    class func gx_day(components: DateComponents) -> String {
        let day = components.day ?? 1
        
        return self.gx_day(day: day)
    }

    /// 根据日期获取日期显示
    /// - Parameter day: 日期
    /// - Returns: 显示日期String
    class func gx_monthDay(month: Int, day: Int) -> String {
        return String(format: "%d.%02d", month, day)
    }
    class func gx_monthDay(components: DateComponents) -> String {
        let month = components.month ?? 1
        let day = components.day ?? 1

        return self.gx_monthDay(month: month, day: day)
    }

    /// 根据日期与指定格式获取字符串
    /// - Parameters:
    ///   - date: 日期
    ///   - format: 日期格式
    /// - Returns: 指定显示日期String
    class func gx_stringDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        formatter.calendar = Calendar.current
        let string = formatter.string(from: date)
        
        return string
    }
}
