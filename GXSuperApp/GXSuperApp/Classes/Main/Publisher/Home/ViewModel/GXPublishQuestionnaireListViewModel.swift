//
//  GXPublishQuestionnaireListViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit

class GXPublishQuestionnaireListViewModel: GXBaseViewModel {
    /// 活动data
    var activityData: GXActivityBaseInfoData!
    /// 分页
    var pageNum: Int = 1
    /// 上下架状态 1-上架中 0-下架中 2-平台禁用 不传-全部
    var shelfStatus: Int?
    /// 问卷状态 0-草稿 1-待审核 2-已审核 3-进行中 4-已结束 5-审核未通过
    var questionaireStatus: Int?
    /// 问卷列表
    var list: [GXPublishQuestionaireDetailData] = []

    /// 获取活动问卷
    func requestGetActivityQuestionaireInfo(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityData.id
        if let questionaireStatus = self.questionaireStatus {
            params["questionaireStatus"] = questionaireStatus
        }
        if let letShelfStatus = self.shelfStatus {
            params["shelfStatus"] = letShelfStatus
        }
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_Activity_GetActivityQuestionaireInfo, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXActivityQuestionaireInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            if let questList = model.data?.activityQuestionaires?.list {
                self.list.append(contentsOf: questList)
            }
            self.pageNum = (self.list.count / PAGE_SIZE) + 1
            success((model.data?.activityQuestionaires?.list.count ?? 0) < PAGE_SIZE)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 删除问卷
    func requestDeleteQuestionaire(index: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let model = self.list[index]
        var params: Dictionary<String, Any> = [:]
        params["questionaireId"] = model.id
        let api = GXApi.normalApi(Api_Quest_DeleteQuestionaire, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXMinePtOrderDetailModel.self, success: { model in
            self.list.remove(at: index)
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
