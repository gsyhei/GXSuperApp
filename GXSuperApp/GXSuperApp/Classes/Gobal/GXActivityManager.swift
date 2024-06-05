//
//  GXCityManager.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/26.
//

import UIKit
import HandyJSON

class GXCitySectionItem: NSObject {
    var cityPinYin: String = ""
    var list: [GXCityItem] = []
}

class GXCityItem: NSObject, HandyJSON {
    var cityCode: String = ""
    var cityName: String = ""

    required override init() {}
    // 首字母
    func firstPinYin() -> String {
        let mutableString = NSMutableString(string: self.cityName)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        if string.count > 0 {
            return string[0].uppercased()
        }
        return "0"
    }
}

class GXCityModel: GXBaseModel {
    var data: [GXCityItem] = []
}

class GXActivityManager: GXBaseViewModel {
    /// 活动类型列表
    var activityTypeList: [GXPrHomeListActivityTypeItem] = []
    /// 城市列表：已按首字母排序
    var cityList: [GXCitySectionItem] = []
    /// 城市列表首字母排序
    var cityListTitles: [String] = []
    /// 热门城市
    var hotCityList: [GXCityItem] = []
    /// 热门搜索
    var hotSearchList: [String] = []
    /// 排序筛选数组
    let sortItems: [GXSelectItem] = {
        return [
            GXSelectItem("默认", nil),
            GXSelectItem("热度", 1),
            GXSelectItem("最近更新", 2),
            GXSelectItem("活动开始时间", 3),
            GXSelectItem("距离", 4)
        ]
    }()
    /// 价格筛选数组
    lazy var priceTypeItems: [GXSelectItem] = {
        return [GXSelectItem("不限", nil),
                GXSelectItem("100以内", 1),
                GXSelectItem("100~300", 2),
                GXSelectItem("300~500", 3),
                GXSelectItem("500以上", 4)]
    }()

    /// 订单赛选周期数组
    lazy var cycleItems: [GXSelectItem] = {
        // 周期 1-本月 2-三个月内 3-半年内 4-一年内 5-三年内
        return [
            GXSelectItem("全部", nil),
            GXSelectItem("本月", 1),
            GXSelectItem("三个月内", 2),
            GXSelectItem("半年内", 3),
            GXSelectItem("一年内", 4),
            GXSelectItem("三年内", 5)
        ]
    }()

    static let shared: GXActivityManager = {
        let instance = GXActivityManager()
        return instance
    }()
    
    /// 城市列表
    func requestListCity(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_HotCity_ListCity, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXCityModel.self, success: { model in
            self.sortCity(list: model.data)
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
    /// 热门城市列表
    func requestListHotCity(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_HotCity_ListHotCity, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXCityModel.self, success: { model in
            self.hotCityList.removeAll()
            for item in model.data {
                if (self.hotCityList.first(where: { $0.cityName == item.cityName }) == nil) {
                    self.hotCityList.append(item)
                }
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 活动类型列表
    func requestListActivityType(success:@escaping(() -> Void), failure:@escaping GXFailure) {
//        if self.activityTypeList.count > 0 {
//            success(); return
//        }
        let api = GXApi.normalApi(Api_CActivity_ListActivityType, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXPrHomeListActivityTypeModel.self, success: { model in
            self.activityTypeList.removeAll()
            for item in model.data {
                if item.showHomePage && !item.deleted {
                    self.activityTypeList.append(item)
                }
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 热门搜索
    func requestGetListHotSearch(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CActivity_ListHotSearch, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXPrHomeHotListSearchModel.self, success: { model in
            self.hotSearchList.removeAll()
            for item in model.data {
                self.hotSearchList.append(item.activityName)
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
}

private extension GXActivityManager {
    /// 排序
    func sortCity(list: [GXCityItem]) {
        var sectionDict: [String: [GXCityItem]] = [:]
        for item in list {
            guard item.cityName.count > 0 else { continue }
            let pinyin = item.firstPinYin()
            if let cityArray = sectionDict[pinyin] {
                sectionDict[pinyin] = cityArray + [item]
            } else {
                sectionDict[pinyin] = [item]
            }
        }
        self.cityListTitles.removeAll()
        self.cityList.removeAll()
        let pinyinArray = sectionDict.keys.sorted(by: <)
        for pinyin in pinyinArray {
            let section = GXCitySectionItem()
            section.cityPinYin = (pinyin == "0") ? "#":pinyin
            section.list = sectionDict[pinyin] ?? []
            self.cityList.append(section)
            self.cityListTitles.append(section.cityPinYin)
        }
    }

}
