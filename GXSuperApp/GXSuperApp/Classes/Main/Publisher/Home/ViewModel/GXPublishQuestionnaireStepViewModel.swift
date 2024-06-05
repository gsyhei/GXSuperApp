//
//  GXPublishQuestionnaireStepViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/18.
//

import UIKit
import RxRelay
import HXPhotoPicker

class GXPublishQuestionnaireStepViewModel: GXBaseViewModel {
    /// 活动data
    var activityId: Int = 0
    /// 问卷data
    var detailData: GXPublishQuestionaireDetailData?
    /// 是否是复制问卷
    var isCopy: Bool = false

    // MARK: - 提交表单
    /// 问卷id
    var questionaireId: Int?
    /// 问卷名称
    var questionaireName = BehaviorRelay<String?>(value: nil)
    /// 问卷对象 1-活动 2-app全员
    var questionaireTarget: Int = 0
    /// 问卷说明
    var questionaireDesc = BehaviorRelay<String?>(value: nil)
    /// 问卷题目
    var questionaireTopics: [GXQuestionairetopicsModel] = []

    /// 获取问卷详情
    func requestGetQuestionaireDetail(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        if self.detailData != nil {
            self.updateInput()
            success()
            return
        }
        let api = GXApi.normalApi(Api_Quest_GetQuestionaireDetail, ["questionaireId":questionaireId ?? 0], .get)
        let cancellable = GXNWProvider.login_request(api, type: GXGetQuestionaireDetailModel.self, success: { model in
            self.detailData = model.data
            self.updateInput()
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 问卷保存草稿
    func requestAllSaveQuestionaireDraft(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let draftData = GXPublishQuestionaireDetailData()
        self.saveStep(data: draftData)
        self.requestSaveQuestionaireDraft(data: draftData, success: success, failure: failure)
    }

    /// 问卷发布
    func requestAllSubmitQuestionaire(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let draftData = GXPublishQuestionaireDetailData()
        self.saveStep(data: draftData)
        self.requestSubmitQuestionaire(data: draftData, success: success, failure: failure)
    }

    /// 问卷编辑
    func requestAllUpdateQuestionaire(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let draftData = GXPublishQuestionaireDetailData()
        self.saveStep(data: draftData)
        self.requestUpdateQuestionaire(data: draftData, success: success, failure: failure)
    }

    /// 问卷草稿发布
    func requestAllSubmitQuestionaireDraft(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        self.requestAllSaveQuestionaireDraft(success: {[weak self] in
            self?.requestSubmitDraftQuestionaire(success: success, failure: failure)
        }, failure: failure)
    }
}

private extension GXPublishQuestionnaireStepViewModel {

    func requestSaveQuestionaireDraft(data: GXPublishQuestionaireDetailData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard let params = data.toJSON() else { return }
        let api = GXApi.normalApi(Api_Quest_SaveQuestionaireDraft, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if let questionaireId = model.data as? Int {
                self.questionaireId = questionaireId
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestSubmitQuestionaire(data: GXPublishQuestionaireDetailData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        data.id = nil
        guard let params = data.toJSON() else { return }
        let api = GXApi.normalApi(Api_Quest_SubmitQuestionaire, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestUpdateQuestionaire(data: GXPublishQuestionaireDetailData, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard let params = data.toJSON() else { return }
        let api = GXApi.normalApi(Api_Quest_UpdateQuestionaire, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestSubmitDraftQuestionaire(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        guard let questionaireId = self.questionaireId else { return }
        let api = GXApi.normalApi(Api_Quest_SubmitDraftQuestionaire, ["questionaireId": questionaireId], .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

}

extension GXPublishQuestionnaireStepViewModel {

    func saveStep(data: GXPublishQuestionaireDetailData) {
        /// 活动id
        data.activityId = self.activityId
        /// 问卷名称
        data.questionaireName = self.questionaireName.value
        /// 问卷ID
        if let letQuestionaireId = self.questionaireId {
            data.id = letQuestionaireId
        }
        /// 问卷说明
        data.questionaireDesc = self.questionaireDesc.value
        /// 问卷对象
        data.questionaireTarget = self.questionaireTarget
        /// 问卷题目
        data.questionaireTopics = self.questionaireTopics
    }

}

extension GXPublishQuestionnaireStepViewModel {

    func updateInput() {
        guard let data = self.detailData else { return }
        // MARK: - Step1

        /// 问卷名称
        self.questionaireName.accept(data.questionaireName)
        /// 问卷说明
        self.questionaireDesc.accept(data.questionaireDesc)
        /// 问卷对象
        self.questionaireTarget = data.questionaireTarget ?? 0

        // MARK: - Step2
        if let questionaireTopics = data.questionaireTopics {
            self.questionaireTopics = questionaireTopics
        }
    }

}
