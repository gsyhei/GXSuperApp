//
//  GXPublishHomeMPActivityViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit

class GXPublishHomeMPActivityViewModel: GXBaseViewModel {
    // MARK: - 入参
    
    /// 日历
    weak var calendarModel: GXHorizontalCalendarDaysModel?
    /// 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过 不传-全部
    var activityStatusList: [String] = []
    /// 分页
    var pageNum: Int = 1
    /// 上下架状态 1-上架中 0-下架中 2-平台禁用 不传-全部
    var shelfStatus: Int?

    // MARK: - request

    /// 活动列表
    var list: [GXActivityBaseInfoData] = []

    /// 请求我发布的活动
    func requestGetListMyActivity(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        if self.activityStatusList.count > 0 {
            let activityStatus = self.activityStatusList.joined(separator: ",")
            params["activityStatusList"] = activityStatus
        }
        if let letShelfStatus = self.shelfStatus {
            params["shelfStatus"] = letShelfStatus
        }
        if let calendar = self.calendarModel {
            if calendar.selectedDates.count == 2 {
                var beginDate: Date, endDate: Date
                if calendar.selectedDates[0] > calendar.selectedDates[1] {
                    beginDate = calendar.selectedDates[1]; endDate = calendar.selectedDates[0]
                } else {
                    beginDate = calendar.selectedDates[0]; endDate = calendar.selectedDates[1]
                }
                params["startDate"] = beginDate.string(format: "yyyyMMdd")
                params["endDate"] = endDate.string(format: "yyyyMMdd")
            }
            else if calendar.selectedDates.count == 1 {
                let date = calendar.selectedDates[0]
                params["startDate"] = date.string(format: "yyyyMMdd")
                params["endDate"] = date.string(format: "yyyyMMdd")
            }
        }
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_Activity_ListMyActivity, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXMyActivityModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            self.list.append(contentsOf: model.data)
            self.pageNum = (self.list.count / PAGE_SIZE) + 1
            if params.count == 2 && self.list.count == 0 {
                GXAppDelegate?.showPublishPopover()
            }
            success(model.data.count < PAGE_SIZE)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
