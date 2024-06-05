//
//  GXPublishQuestionnaireStep2VC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/19.
//

import UIKit
import GXTransition_Swift
import MBProgressHUD

class GXPublishQuestionnaireStep2VC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    /// 底部栏
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    weak var viewModel: GXPublishQuestionnaireStepViewModel!

    private lazy var addButton: UIButton = {
        return UIButton(type: .system).then {
            $0.contentHorizontalAlignment = .right
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.tintColor = .gx_green
            $0.setTitle("添加题目", for: .normal)
            $0.setImage(UIImage(named: "aw_add"), for: .normal)
            $0.addTarget(self, action: #selector(self.addButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var addButtonConView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.width, height: 40)).then {
            $0.backgroundColor = .gx_black
            $0.addSubview(self.addButton)
            self.addButton.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
            }
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        if self.viewModel.questionaireId != nil && !self.viewModel.isCopy {
            self.title = "编辑问卷"
        } else {
            self.title = "新建问卷"
        }

        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.saveButton.setBackgroundColor(.white, for: .normal)
        self.submitButton.setBackgroundColor(.gx_green, for: .normal)

        self.tableView.register(headerFooterViewType: GXPublishQuestionnaireOptionHeader.self)
        self.tableView.register(cellType: GXPublishQuestionnaireOptionCell.self)
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 60.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 40.0

        self.tableView.setAddButton(title: "添加题目", type: 1) {[weak self] in
            guard let `self` = self else { return }
            self.editingQuestionaireTopics()
        }
        self.tableView.placeholder = "请添加问卷题目"
        self.tableViewReloadData()

        if !self.viewModel.isCopy && self.viewModel.detailData?.questionaireStatus ?? 0 > 0 {
            self.submitButton.setTitle("保存", for: .normal)
        }
        else {
            self.submitButton.setTitle("发布", for: .normal)
        }
    }

}

private extension GXPublishQuestionnaireStep2VC {
    func tableViewReloadData() {
        self.tableView.gx_reloadData()
        if self.tableView.placeholderView.isHidden {
            self.tableView.tableHeaderView = self.addButtonConView
        } else {
            self.tableView.tableHeaderView = nil
        }
    }

    func requestSaveQuestionaireDraft() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllSaveQuestionaireDraft(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "保存成功", to: self?.view)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestAllSubmitQuestionaire() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllSubmitQuestionaire(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.showSubmitSuccessAlert()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func showSubmitSuccessAlert() {
        if self.viewModel.questionaireTarget == 1 {
            GXToast.showSuccess(text: "发布成功")
            self.navigationController?.popToViewController(vcType: GXPublishQuestionnaireVC.self, animated: true)
            return
        }
        let title = "提交成功\n平台会在1-2个工作日内审核\n请耐心等待！"
        GXUtil.showAlert(title: title, cancelTitle: "我知道了") { alert, index in
            self.navigationController?.popToViewController(vcType: GXPublishQuestionnaireVC.self, animated: true)
        }
    }
    
    func requestAllUpdateQuestionaire() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllUpdateQuestionaire(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "修改成功")
            self?.navigationController?.popToViewController(vcType: GXPublishQuestionnaireVC.self, animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestAllSubmitQuestionaireDraft() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAllSubmitQuestionaireDraft(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.showSubmitSuccessAlert()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func showEditingAlert(index: Int) {
        GXUtil.showAlert(to: self,
                         style: .actionSheet,
                         other: ["编辑题目", "删除题目"]) { actionIndex in
            switch actionIndex {
            case 1:
                self.editingQuestionaireTopics(index: index)
            case 2:
                self.viewModel.questionaireTopics.remove(at: index)
                self.tableViewReloadData()
            default: break
            }
        }
    }

    func editingQuestionaireTopics(index: Int? = nil) {
        var model: GXQuestionairetopicsModel
        if let editIndex = index {
            model = self.viewModel.questionaireTopics[editIndex]
        } else {
            model = GXQuestionairetopicsModel()
            self.viewModel.questionaireTopics.append(model)
        }
        let index = self.viewModel.questionaireTopics.firstIndex(of: model)
        let view = GXPublishQuestionnaireStep2View.createView(model: model, index: index)
        var rect = self.view.bounds
        rect.size.height = self.view.bounds.height - 100
        view.frame = rect
        view.show(to: self.view, style: .sheetBottom, usingSpring: true)
        view.saveAction = {[weak self] topicsModel in
            guard let `self` = self else { return }
            self.tableViewReloadData()
        }
    }

}

extension GXPublishQuestionnaireStep2VC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.questionaireTopics.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.questionaireTopics[section].questionaireTopicOptions?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishQuestionnaireOptionCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.questionaireTopics[safe: indexPath.section]?.questionaireTopicOptions?[indexPath.row]
        cell.bindCell(model: model)
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXPublishQuestionnaireOptionHeader.self)
        let model = self.viewModel.questionaireTopics[section]
        header?.bindView(model: model, section: section)
        header?.editAction = {[weak self] curHeader in
            guard let `self` = self else { return }
            self.showEditingAlert(index: curHeader.section)
        }
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension GXPublishQuestionnaireStep2VC {

    @objc func addButtonClicked(_ sender: UIButton?) {
        self.editingQuestionaireTopics()
    }

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.requestSaveQuestionaireDraft()
    }

    @IBAction func submitButtonClicked(_ sender: UIButton) {
        if self.viewModel.questionaireTopics.count == 0 {
            GXToast.showError(text: "请先添加题目！")
            return
        }
        if self.viewModel.isCopy {
            // 发布
            self.requestAllSubmitQuestionaire()
        }
        else {
            if self.viewModel.detailData?.questionaireStatus ?? 0 > 0 {
                // 编辑保存
                self.requestAllUpdateQuestionaire()
            }
            else {
                // 草稿发布
                self.requestAllSubmitQuestionaireDraft()
            }
        }
    }

}
