//
//  GXPublishQuestDetailTopicViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit

class GXPublishQuestDetailTopicViewModel: GXBaseViewModel {
    /// 问卷统计
    var reportData: GXQuestionaireReportData?
    /// 活动data
    var activityData: GXActivityBaseInfoData!
    /// 问卷data
    var data: GXPublishQuestionaireDetailData!

    /// 问卷上架-下架
    func requestModifyQuestionaireShelf(success:@escaping((Int) -> Void), failure:@escaping GXFailure) {
        //shelfStatus 上下架状态 1-上架中 0-下架中 2-平台禁用
        var shelfStatus = self.data?.shelfStatus ?? 0
        shelfStatus = (shelfStatus == 1) ? 0 : 1
        let params: [String : Any] = ["questionaireId": self.data?.id ?? 0]
        let api = GXApi.normalApi(Api_Quest_ModifyQuestionaireShelf, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            self.data.shelfStatus = shelfStatus
            success(shelfStatus)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 结束问卷
    func requestStopQuestionaire(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        // questionaireStatus 问卷状态 0-草稿 1-待审核 2-已审核 3-进行中 4-已结束 5-审核未通过
        let params: [String : Any] = ["questionaireId": self.data?.id ?? 0]
        let api = GXApi.normalApi(Api_Quest_StopQuestionaire, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            self.data.questionaireStatus = 4
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }    

    /// 获取问卷详情
    func requestGetQuestionaireDetail(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let params: [String : Any] = ["questionaireId": self.data?.id ?? 0]
        let api = GXApi.normalApi(Api_Quest_GetQuestionaireDetail, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetQuestionaireDetailModel.self, success: { model in
            if let detailData = model.data {
                self.data.shelfStatus = detailData.shelfStatus
                self.data.questionaireStatus = detailData.questionaireStatus
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}
