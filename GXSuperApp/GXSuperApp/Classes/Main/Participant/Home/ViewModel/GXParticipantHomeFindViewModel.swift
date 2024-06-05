//
//  GXParticipantHomeFindViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/6.
//

import UIKit
import XCGLogger

class GXParticipantHomeFindViewModel: GXBaseViewModel {
    var musicList: [GXPtHomeGetMusicStationsItem] = []
    var bannerList: [GXPtHomeListBannerItem] = []
    var aqtData: GXPtHomeActQueTicketData?

    // MARK: - 入参
    /// 活动类型索引
    var activityTypeIds: [String] = []
    /// 进行中/即将开始活动
    var mySignIndex: Int = 0
    /// tab类型   1-即将开售 2-预售早鸟
    var tabType: Int = 1
    /// 活动价格 1-100以内 2-100~300 3-300~500 4-500以上
    var priceType: Int?

    // MARK: - 拉取

    /// 电台section动态显示数据
    var dtSectionList: [Any] = []
    /// 进行中/即将开始活动
    var mySignTabNumber: Int = 0
    var mySignActivityData: GXPtHomeMySignActivityData?
    /// 即将开售/预售早鸟
    var activityPageList: [GXActivityBaseInfoData] = []

    /// 首页数据全部拉取线程
    func requestGetAllData(success:@escaping(() -> Void), stepSuccess:@escaping(() -> Void), failure:@escaping GXFailure) {
        let group = DispatchGroup()
        group.enter()
        self.requestGetMusicStations(success: {
            DispatchQueue.main.async {
                stepSuccess()
            }
            group.leave()
        }) { error in
            failure(error)
            group.leave()
        }

        group.enter()
        self.requestGetListBanner(success: {
            DispatchQueue.main.async {
                stepSuccess()
            }
            group.leave()
        }) { error in
            failure(error)
            group.leave()
        }

        if GXUserManager.shared.isLogin {
            group.enter()
            self.requestGetMySignActivity(success: {
                DispatchQueue.main.async {
                    stepSuccess()
                }
                group.leave()
            }) { error in
                failure(error)
                group.leave()
            }
        }

        group.enter()
        GXActivityManager.shared.requestListActivityType(success: {[weak self] in
            self?.requestGetActivityPage(success: {
                DispatchQueue.main.async {
                    stepSuccess()
                }
                group.leave()
            }, failure: { error in
                failure(error)
                group.leave()
            })
        }) { error in
            failure(error)
            group.leave()
        }

        group.enter()
        self.requestGetActivityAndQuestionaireAndTicket(success: {
            DispatchQueue.main.async {
                stepSuccess()
            }
            group.leave()
        }) { error in
            failure(error)
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            XCGLogger.info("主页数量全部拉取完成。")
            success()
        }
    }

    /// 拉取需要city的数据
    func requestCityActivityPage(success:@escaping(() -> Void), stepSuccess:@escaping(() -> Void), failure:@escaping GXFailure) {
        let group = DispatchGroup()
        group.enter()
        GXActivityManager.shared.requestListActivityType(success: {[weak self] in
            self?.requestGetActivityPage(success: {
                DispatchQueue.main.async {
                    stepSuccess()
                }
                group.leave()
            }, failure: { error in
                failure(error)
                group.leave()
            })
        }) { error in
            failure(error)
            group.leave()
        }

        group.enter()
        self.requestGetActivityAndQuestionaireAndTicket(success: {
            DispatchQueue.main.async {
                stepSuccess()
            }
            group.leave()
        }) { error in
            failure(error)
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            XCGLogger.info("主页需要city部分全部拉取完成。")
            success()
        }
    }
}

extension GXParticipantHomeFindViewModel {
    /// 电台
    func requestGetMusicStations(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_Home_GetMusicStations, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXPtHomeGetMusicStationsModel.self, success: { model in
            self.musicList.removeAll()
            for item in model.data {
                if item.showHomePage && !item.deleted {
                    self.musicList.append(item)
                }
            }
            self.updateDtList()
            GXMusicPlayerManager.shared.updateMusicPlayerList(list: self.musicList)
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// Banner
    func requestGetListBanner(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CActivity_ListBanner, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXPtHomeListBannerModel.self, success: { model in
            self.bannerList.removeAll()
            for item in model.data {
                if item.bannerStatus == 1 && !item.deleted {
                    self.bannerList.append(item)
                }
            }
            self.updateDtList()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 活动日历问卷标题抢票播报
    func requestGetActivityAndQuestionaireAndTicket(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        var params: Dictionary<String, Any> = [:]
        params["city"] = GXUserManager.shared.city
        let api = GXApi.normalApi(Api_CActivity_GetActivityAndQuestionaireAndTicket, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXPtHomeActQueTicketModel.self, success: { model in
            self.aqtData = model.data
            self.updateDtList()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 进行中即将开始活动
    func requestGetMySignActivity(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CActivity_MySignActivity, [:], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXPtHomeMySignActivityModel.self, success: { model in
            self.mySignActivityData = model.data
            self.mySignTabNumber = self.mySignActivityData?.isTabNumber() ?? 0
            self.mySignIndex = self.mySignActivityData?.selectedIndex() ?? 0
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
    
    /// 即将开售/预售早鸟
    func requestGetActivityPage(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        // tabType         tab类型 1-即将开售 2-预售早鸟
        // city            城市
        // activityTypeIds 活动类型列表
        // priceType       活动价格 1-100以内 2-100~300 3-300~500 4-500以上
        var params: Dictionary<String, Any> = [:]
        params["tabType"] = self.tabType
        params["city"] = GXUserManager.shared.city

        if self.activityTypeIds.count > 0 {
            params["activityTypeIds"] = self.activityTypeIds.joined(separator: ",")
        }
        if let letPriceType = self.priceType {
            params["priceType"] = letPriceType
        }
        let api = GXApi.normalApi(Api_CActivity_Page, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXPtHomeActivityPageModel.self, success: { model in
            self.activityPageList = model.data
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 更新电台section栏数据
    func updateDtList() {
        self.dtSectionList.removeAll()
        if self.musicList.count > 0 {
            self.dtSectionList.append(self.musicList)
        }
        if self.bannerList.count > 0 {
            self.dtSectionList.append(self.bannerList)
        }
        if let data = self.aqtData {
            self.dtSectionList.append(data)
        }
    }

    /// 活动基础信息
    func requestGetActivityBaseInfo(activityId: Int, success:@escaping((GXActivityBaseInfoData?) -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_CActivity_GetActivityBaseInfo, ["id": activityId], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityBaseInfoModel.self, success: { model in
            success(model.data)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
