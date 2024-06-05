//
//  GXPtQuestionnaireSubmitVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/31.
//

import UIKit
import MBProgressHUD

class GXPtQuestionnaireSubmitVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var submitButton: UIButton!

    private var questionaireId: Int?
    private var questionaireData: GXPublishQuestionaireDetailData?
    private var isQuestEnd: Bool = false
    private var currentTopics: [GXQuestionairetopicsModel] = []

    class func createVC(questionaireData: GXPublishQuestionaireDetailData? = nil, questionaireId: Int? = nil) -> GXPtQuestionnaireSubmitVC {
        return GXPtQuestionnaireSubmitVC.xibViewController().then {
            $0.questionaireData = questionaireData
            if let questionaireData = questionaireData {
                $0.questionaireId = questionaireData.id
            }
            else if let questionaireId = questionaireId {
                $0.questionaireId = questionaireId
            }
            $0.hidesBottomBarWhenPushed = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        GXApiUtil.requestCreateEvent(targetType: 12, targetId: self.questionaireId)
    }

    override func setupViewController() {
        self.gx_addBackBarButtonItem()

        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.submitButton.setBackgroundColor(.gx_lightGray, for: .disabled)
        self.submitButton.setTitleColor(.gx_black, for: .normal)
        self.submitButton.setTitleColor(.gx_drakGray, for: .disabled)
        self.submitButton.isEnabled = false

        self.tableView.separatorColor = .gx_lightGray
        self.tableView.register(cellType: GXPublishQuestionnaireOptionCell.self)
        self.tableView.register(headerFooterViewType: GXPublishQuestionnaireDetailTopSection.self)
        self.tableView.register(headerFooterViewType: GXPtQuestionnaireSubmitTopHeader.self)

        if self.questionaireData == nil {
            self.requestGetQuestionaireDetail()
        }
        else {
            self.canNullQuestionaireTopics()
        }
    }
}

extension GXPtQuestionnaireSubmitVC {
    
    func requestGetQuestionaireDetail() {
        guard let questionaireId = self.questionaireId else { return }
        MBProgressHUD.showLoading(to: self.view)
        let params = ["questionaireId": questionaireId]
        let api = GXApi.normalApi(Api_CActivityQuest_GetQuestionaireDetail, params, .get)
        GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if let dataJSON = model.data as? Dictionary<String, Any> {
                self.questionaireData = GXPublishQuestionaireDetailData.deserialize(from: dataJSON)
                self.canNullQuestionaireTopics()
            }
            MBProgressHUD.dismiss(for: self.view)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestSubmitQuestionaireAnswer(params: [String: Any]) {
        MBProgressHUD.showLoading(to: self.view)
        let api = GXApi.normalApi(Api_CActivityQuest_SubmitQuestionaireAnswer, params, .post)
        GXNWProvider.login_request(api, type: GXBaseModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "提交成功")
            self.popToQuestionnaireListVC()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func popToQuestionnaireListVC() {
        let vcType = GXPtQuestionnaireListVC.self
        if self.navigationController?.popToViewController(vcType: vcType, animated: true) == nil {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    func canNullQuestionaireTopics() {
        guard let questTopics = self.questionaireData?.questionaireTopics, questTopics.count > 0 else {
            GXToast.showError(text: "该问卷无题目可选！")
            self.navigationController?.popViewController(animated: true)
            return
        }
        let allCount = self.questionaireData?.questionaireTopics?.count ?? 0
        var currentCount = 0
        if allCount > 3 {
            currentCount = 3
            self.isQuestEnd = false
        } else {
            currentCount = allCount
            self.isQuestEnd = true
        }
        self.title = "问卷 \(currentCount)/\(allCount)"
        let array = self.questionaireData?.questionaireTopics?[0..<currentCount]
        self.currentTopics = Array(array ?? [])
        self.tableView.reloadData()

        let questAnswers = self.questionaireData?.questionaireAnswers ?? []
        if self.isQuestEnd {
            if questAnswers.count > 0 {
                self.submitButton.setTitle("此问卷您已提交", for: .disabled)
            }
            else {
                self.submitButton.setTitle("提交", for: .normal)
            }
        }
        else {
            self.submitButton.setTitle("下一步", for: .normal)
        }
        guard questAnswers.count > 0 else { return }
        for section in 0..<self.currentTopics.count {
            let topicsModel = self.currentTopics[section]
            for row in 0..<(topicsModel.questionaireTopicOptions?.count ?? 0) {
                guard let option = topicsModel.questionaireTopicOptions?[row] else { continue }
                guard (questAnswers.first(where: { $0.topicId == topicsModel.id && $0.optionId == option.id }) != nil) else { continue }
                let indexPath = IndexPath(row: row, section: section + 1)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        self.submitButton.isEnabled = !self.isQuestEnd
        self.tableView.allowsSelection = false
    }
}

extension GXPtQuestionnaireSubmitVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.currentTopics.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section > 0 else { return 0 }

        let count = self.currentTopics[section - 1].questionaireTopicOptions?.count
        return (count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section > 0 else { return UITableViewCell() }

        let cell: GXPublishQuestionnaireOptionCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.currentTopics[indexPath.section - 1].questionaireTopicOptions?[indexPath.row]
        cell.bindCell(model: model, isDetail: true)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(GXPtQuestionnaireSubmitTopHeader.self)
            header?.bindView(model: self.questionaireData)
            return header
        }
        let header = tableView.dequeueReusableHeaderFooterView(GXPublishQuestionnaireDetailTopSection.self)
        let model = self.currentTopics[section - 1]
        header?.bindView(model: model, section: section)

        return header
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else { return 80.0 }
        return 40.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.section > 0 else { return .zero }
        return 40.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        let model = self.currentTopics[indexPath.section - 1]

        // 题目类型 1-单选 2-多选
        if model.topicType == 1 {
            for selectIndexPath in tableView.indexPathsForSelectedRows ?? [] {
                guard indexPath.section == selectIndexPath.section else { continue }
                guard indexPath.row != selectIndexPath.row else { continue }

                tableView.deselectRow(at: selectIndexPath, animated: true)
            }
        }
        self.checkSubmitButton()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.checkSubmitButton()
    }

    func checkSubmitButton() {
        // 校验提交按钮
        var sections: Set<Int> = []
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            sections.update(with: indexPath.section)
        }
        let topicsCount = self.currentTopics.count
        self.submitButton.isEnabled = sections.count == topicsCount
    }
}

extension GXPtQuestionnaireSubmitVC {
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        var selectDict: [Int: [Int]] = [:]
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            let topic = self.currentTopics[indexPath.section - 1]
            guard let topicOption = topic.questionaireTopicOptions?[indexPath.row] else { continue }
            guard let topicId = topic.id else { continue }
            guard let topicOptionId = topicOption.id else { continue }

            if let selectItemArr = selectDict[topicId] {
                selectDict.updateValue(selectItemArr + [topicOptionId], forKey: topicId)
            }
            else {
                selectDict.updateValue([topicOptionId], forKey: topicId)
            }
        }
        var topicAnswers: [Dictionary<String, Any>] = []
        for (key, value) in selectDict {
            var topicAnswerItem: Dictionary<String, Any> = [:]
            topicAnswerItem["topicId"] = key
            topicAnswerItem["optionIds"] = value
            topicAnswers.append(topicAnswerItem)
        }
        if self.isQuestEnd {
            var params: Dictionary<String, Any> = [:]
            params["questionaireId"] = self.questionaireData?.id
            params["topicAnswers"] = topicAnswers
            self.requestSubmitQuestionaireAnswer(params: params)
        }
        else {
            guard let data = self.questionaireData else { return }
            let vc = GXPtQuestionnaireNextVC.createVC(questionaireData: data, topicAnswers: topicAnswers)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
