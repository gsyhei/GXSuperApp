//
//  GXPtQuestionnaireNextVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/31.
//

import UIKit
import MBProgressHUD

class GXPtQuestionnaireNextVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!

    private var questionaireData: GXPublishQuestionaireDetailData!
    private var topicAnswers: [Dictionary<String, Any>] = []
    private var index: Int = 0
    private var count: Int = 0
    private var isQuestEnd: Bool = false
    private var currentTopics: [GXQuestionairetopicsModel] = []

    class func createVC(questionaireData: GXPublishQuestionaireDetailData,
                        topicAnswers: [Dictionary<String, Any>]) -> GXPtQuestionnaireNextVC
    {
        return GXPtQuestionnaireNextVC.xibViewController().then {
            $0.hidesBottomBarWhenPushed = true
            $0.questionaireData = questionaireData
            $0.topicAnswers = topicAnswers
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.gx_addBackBarButtonItem()

        self.previousButton.setBackgroundColor(.gx_green, for: .normal)
        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.submitButton.setBackgroundColor(.gx_lightGray, for: .disabled)
        self.submitButton.setTitleColor(.gx_black, for: .normal)
        self.submitButton.setTitleColor(.gx_drakGray, for: .disabled)
        self.submitButton.isEnabled = false

        self.tableView.separatorColor = .gx_lightGray
        self.tableView.register(cellType: GXPublishQuestionnaireOptionCell.self)
        self.tableView.register(headerFooterViewType: GXPublishQuestionnaireDetailTopSection.self)
        self.tableView.register(headerFooterViewType: GXPtQuestionnaireSubmitTopHeader.self)
        
        let array = questionaireData.questionaireTopics?[self.index..<(self.index + self.count)]
        self.currentTopics = Array(array ?? [])
        self.canNullQuestionaireTopics()
    }
}

extension GXPtQuestionnaireNextVC {

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
        let index = self.topicAnswers.count
        var currentCount = questTopics.count - index
        if currentCount > 3 {
            currentCount = 3
            self.isQuestEnd = false
        } else {
            self.isQuestEnd = true
        }
        let endCount = index + currentCount
        self.title = "问卷 \(endCount)/\(questTopics.count)"
        let currentTopics = questTopics[index..<endCount]
        self.currentTopics = Array(currentTopics)
        self.tableView.reloadData()

        let questAnswers = self.questionaireData?.questionaireAnswers ?? []
        if self.isQuestEnd {
            if questAnswers.count > 0 {
                self.submitButton.setTitle("此问卷您已提交", for: .disabled)
            }
            else {
                self.submitButton.setTitle("提交", for: .normal)
                if (self.questionaireData?.questionaireStatus ?? 0) == 4 {
                    self.submitButton.setTitle("问卷已结束", for: .disabled)
                    self.submitButton.isEnabled = false
                    self.tableView.allowsSelection = false
                    return
                }
            }
        }
        else {
            self.submitButton.setTitle("下一步", for: .normal)
            if (self.questionaireData?.questionaireStatus ?? 0) == 4 {
                self.tableView.allowsSelection = false
                return
            }
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

extension GXPtQuestionnaireNextVC: UITableViewDataSource, UITableViewDelegate {

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
        header?.bindView(model: model, section: self.topicAnswers.count + section)

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

extension GXPtQuestionnaireNextVC {
    @IBAction func previousButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
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
        self.topicAnswers.append(contentsOf: topicAnswers)
        if self.isQuestEnd {
            var params: Dictionary<String, Any> = [:]
            params["questionaireId"] = self.questionaireData?.id
            params["topicAnswers"] = self.topicAnswers
            self.requestSubmitQuestionaireAnswer(params: params)
        }
        else {
            guard let data = self.questionaireData else { return }
            let vc = GXPtQuestionnaireNextVC.createVC(questionaireData: data, topicAnswers: self.topicAnswers)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
