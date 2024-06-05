//
//  GXPublishQuestionnaireListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import MBProgressHUD
import GXRefresh

class GXPublishQuestionnaireListVC: GXBaseViewController {

    private var statusMenu: GXSelectItemsMenu?
    private var addedStatusMenu: GXSelectItemsMenu?
    private var isViewDidAppear: Bool = false

    lazy var topContentView: UIView = {
        return UIView().then {
            $0.backgroundColor = .white
        }
    }()

    lazy var questionaireStatusButton: GXArrowButton = {
        return GXArrowButton(type: .custom).then {
            $0.contentHorizontalAlignment = .center
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 120, height: 40))
            $0.setTitle("问卷状态", for: .normal)
            $0.setTitleColor(.gx_textBlack, for: .normal)
            $0.setImage(UIImage(named: "pr_wz_arraw"), for: .normal)
            $0.titleLabel?.font = .gx_font(size: 14)
            $0.addTarget(self, action: #selector(questionaireStatusButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    lazy var contentView: UIView = {
        return UIView().then {
            $0.backgroundColor = .white
        }
    }()

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .gx_background
            $0.separatorColor = .gx_lightGray
            $0.rowHeight = 74.0
            $0.dataSource = self
            $0.delegate = self
            $0.setAddButton(title: "添加问卷调查", type: 0) {[weak self] in
                guard let `self` = self else { return }
                self.showQuestOperation()
            }
            $0.placeholder = "暂无问卷调查"
            $0.register(cellType: GXPublishQuestionnaireListCell.self)
        }
    }()

    private lazy var viewModel: GXPublishQuestionnaireListViewModel = {
        return GXPublishQuestionnaireListViewModel()
    }()

    required init(activityData: GXActivityBaseInfoData, shelfStatus: Int) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.activityData = activityData
        self.viewModel.shelfStatus = shelfStatus
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.questionaireStatusButton.imageLocationAdjust(model: .right, spacing: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.isViewDidAppear {
            self.requestRefreshData(isShowHud: false)
        }
        self.isViewDidAppear = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
    }

    override func setupViewController() {
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.tableView)
        self.view.addSubview(self.topContentView)
        self.topContentView.addSubview(self.questionaireStatusButton)

        self.topContentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(42)
        }
        self.questionaireStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(36)
        }
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.topContentView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requestData(isRefresh: true, isShowHud: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_header?.endRefreshing(isNoMore: isLastPage, isSucceed: isSucceed)
            })
        }).then({ header in
            header.updateRefreshTitles()
        })
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
            self?.requestData(isRefresh: false, isShowHud: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
            })
        }).then { footer in
            footer.updateRefreshTitles()
        }
    }

    func hideMenu() {
        if self.questionaireStatusButton.isSelected {
            self.questionaireStatusButtonClicked(self.questionaireStatusButton)
        }
    }

    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetActivityQuestionaireInfo(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
            completion?(true, isLastPage)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            completion?(false, false)
        })
    }

    func requestRefreshData(isShowHud: Bool = true) {
        self.requestData(isRefresh: true, isShowHud: isShowHud) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }

    func requestDeleteQuestionaire(index: Int) {
        let model = self.viewModel.list[index]
        if (model.submitNum ?? 0) > 0 {
            GXToast.showError(text: "已有用户提交问卷答案，无法删除")
            return
        }
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestDeleteQuestionaire(index: index, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXPublishQuestionnaireListVC {

    func showQuestOperation() {
        let pickerView: GXQuestPickerView = {
            return GXQuestPickerView.xibView().then {
                $0.backgroundColor = .white
                $0.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 360)
                $0.completion = {[weak self] model in
                    guard let `self` = self else { return }
                    if let data = model.data {
                        let vc = GXPublishQuestionnaireStep1VC.createVC(activityId: self.viewModel.activityData.id, questionaireId: data.id, isCopy: true)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        let vc = GXPublishQuestionnaireStep1VC.createVC(activityId: self.viewModel.activityData.id)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }()
        pickerView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    @objc func questionaireStatusButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.statusMenu?.hide(animated: true)
            return
        }
        // 0-草稿 1-待审核 2-已审核 3-进行中 4-已结束 5-审核未通过
        let items: [GXSelectItem] = {
            return [
                GXSelectItem("全部", nil),
                GXSelectItem("草稿", 0),
                GXSelectItem("待审核", 1),
                GXSelectItem("已审核", 2),
                GXSelectItem("进行中", 3),
                GXSelectItem("已结束", 4),
                GXSelectItem("审核未通过", 5),
            ]
        }()
        let menu = GXSelectItemsMenu(items: items, multipleSelection: false)
        menu.show(to: self.contentView, style: .sheetTop, dismissBlock: {[weak self] in
            self?.questionaireStatusButton.isSelected = false
        })
        menu.selected(status: self.viewModel.questionaireStatus)
        menu.selectedAction = {[weak self] selectedItems in
            self?.viewModel.questionaireStatus = selectedItems.first?.status
            self?.questionaireStatusButton.setTitle(selectedItems.first?.title, for: .normal)
            self?.requestRefreshData()
        }
        self.statusMenu = menu
    }

}

extension GXPublishQuestionnaireListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishQuestionnaireListCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindCell(model: model)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        if model.questionaireStatus == 0 {
            let vc = GXPublishQuestionnaireStep1VC.createVC(activityId: self.viewModel.activityData.id, data: model)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = GXPublishQuestionnaireDetailVC.createVC(activityData: self.viewModel.activityData, detailData: model)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除", handler: { (action, view, completion) in
            GXUtil.showAlert(title: "确认删除该问卷？", actionTitle: "确定") { alert, index in
                completion(true)
                guard index == 1 else { return }
                self.requestDeleteQuestionaire(index: indexPath.row)
            }
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}

