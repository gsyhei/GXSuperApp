//
//  GXPublishQuestDetailTopicVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/21.
//

import UIKit
import MBProgressHUD

class GXPublishQuestDetailTopicVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var enableButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    private lazy var viewModel: GXPublishQuestDetailTopicViewModel = {
        return GXPublishQuestDetailTopicViewModel()
    }()

    class func createVC(activityData: GXActivityBaseInfoData, detailData: GXPublishQuestionaireDetailData?) -> GXPublishQuestDetailTopicVC {
        return GXPublishQuestDetailTopicVC.xibViewController().then {
            $0.viewModel.activityData = activityData
            $0.viewModel.data = detailData
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestGetQuestionaireDetail()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.tableView.register(headerFooterViewType: GXPublishQuestionnaireDetailTopSection.self)
        self.tableView.register(cellType: GXPublishQuestionnaireDetailTopCell.self)
        self.tableView.register(cellType: GXPublishQuestionnaireOptionCell.self)

        self.updateBottomButton()
    }

    func updateReportData(_ reportData: GXQuestionaireReportData?) {
        self.viewModel.reportData = reportData
        self.updateBottomButton()
    }

    func updateBottomButton() {
        guard let letData = self.viewModel.data else { return }

        //questionaireStatus 问卷状态 0-草稿 1-待审核 2-已审核 3-进行中 4-已结束 5-审核未通过
        //shelfStatus        上下架状态 1-上架中 0-下架中 2-平台禁用
        if letData.questionaireStatus == 1 {
            self.enableButton.setTitle("上架", for: .normal)
            self.endButton.setTitle("结束", for: .normal)
            self.editButton.setTitle("编辑", for: .normal)
            self.enableButton.gx_setDisabledButton()
            self.endButton.gx_setDisabledButton()
            self.editButton.gx_setDisabledButton()
        }
        else if letData.questionaireStatus == 2 || letData.questionaireStatus == 3 {
            if letData.shelfStatus == 1 {
                self.enableButton.setTitle("下架", for: .normal)
            } else {
                self.enableButton.setTitle("上架", for: .normal)
            }
            self.endButton.setTitle("结束", for: .normal)
            self.editButton.setTitle("编辑", for: .normal)
            self.enableButton.gx_setGreenButton()
            self.endButton.gx_setRedBorderButton()
            if let submitNum = self.viewModel.reportData?.submitNum, submitNum == 0 {
                self.editButton.gx_setGreenButton()
            } else {
                self.editButton.gx_setGrayButton()
            }
        }
        else if letData.questionaireStatus == 4 {
            if letData.shelfStatus == 1 {
                self.enableButton.setTitle("已上架", for: .normal)
            } else {
                self.enableButton.setTitle("已下架", for: .normal)
            }
            self.endButton.setTitle("结束", for: .normal)
            self.editButton.setTitle("编辑", for: .normal)
            self.enableButton.gx_setDisabledButton()
            self.endButton.gx_setDisabledButton()
            self.editButton.gx_setDisabledButton()
        }
        else if letData.questionaireStatus == 5 {
            if letData.shelfStatus == 1 {
                self.enableButton.setTitle("已上架", for: .normal)
            } else {
                self.enableButton.setTitle("已下架", for: .normal)
            }
            self.endButton.setTitle("结束", for: .normal)
            self.editButton.setTitle("编辑", for: .normal)
            self.enableButton.gx_setDisabledButton()
            self.endButton.gx_setDisabledButton()
            if let submitNum = self.viewModel.reportData?.submitNum, submitNum == 0 {
                self.editButton.gx_setGreenButton()
            } else {
                self.editButton.gx_setGrayButton()
            }
        }
    }
}

extension GXPublishQuestDetailTopicVC {
    
    func requestModifyQuestionaireShelf() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestModifyQuestionaireShelf(success: {[weak self] shelfStatus in
            MBProgressHUD.dismiss(for: self?.view)
            if shelfStatus == 1 {
                GXToast.showSuccess(text: "已上架")
            } else {
                GXToast.showSuccess(text: "已下架")
            }
            self?.updateBottomButton()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestStopQuestionaire() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestStopQuestionaire(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "已结束")
            self?.updateBottomButton()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestGetQuestionaireDetail() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetQuestionaireDetail(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateBottomButton()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPublishQuestDetailTopicVC {

    @IBAction func enableButtonClicked(_ sender: UIButton) {
        self.requestModifyQuestionaireShelf()
    }
    @IBAction func endButtonClicked(_ sender: UIButton) {
        GXUtil.showAlert(title: "确定要结束问卷吗？", actionTitle: "确定") { alert, index in
            guard index == 1 else { return }
            self.requestStopQuestionaire()
        }
    }
    @IBAction func editButtonClicked(_ sender: UIButton) {
        if let submitNum = self.viewModel.reportData?.submitNum, submitNum > 0 {
            GXToast.showError(text: "已有用户回答了问卷，无法编辑")
            return
        }
        let vc = GXPublishQuestionnaireStep1VC.createVC(activityId: self.viewModel.activityData.id, data: self.viewModel.data)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension GXPublishQuestDetailTopicVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.viewModel.data?.questionaireTopics?.count ?? 0) + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let count = self.viewModel.data?.questionaireTopics?[section - 1].questionaireTopicOptions?.count
        return (count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: GXPublishQuestionnaireDetailTopCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.data)

            return cell
        }
        let cell: GXPublishQuestionnaireOptionCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.data?.questionaireTopics?[indexPath.section - 1].questionaireTopicOptions?[indexPath.row]
        cell.bindCell(model: model, isDetail: true)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(GXPublishQuestionnaireDetailTopSection.self)
        let model = self.viewModel.data?.questionaireTopics?[section - 1]
        header?.bindView(model: model, section: section)

        return header
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 40.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 212.0
        }
        return 40.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
