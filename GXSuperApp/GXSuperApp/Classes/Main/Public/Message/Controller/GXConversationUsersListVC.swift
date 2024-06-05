//
//  GXConversationUsersListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit
import MBProgressHUD
import GXRefresh

class GXConversationUsersListVC: GXBaseViewController {
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.placeholder = "暂无消息"
            $0.rowHeight = 64.0
            $0.dataSource = self
            $0.delegate = self
        }
    }()

    lazy var searchView: UIView = {
        let rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 56)
        return UIView(frame: rect).then {
            $0.backgroundColor = .white
            $0.addSubview(self.searchButton)
            self.searchButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-12)
            }
        }
    }()

    lazy var searchButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setTitle("搜活动名称", for: .normal)
            $0.setTitleColor(.gx_gray, for: .normal)
            let searchImage = UIImage(named: "pr_search_icon")?.withRenderingMode(.alwaysTemplate)
            $0.setImage(searchImage, for: .normal)
            $0.setBackgroundColor(.gx_background, for: .normal)
            $0.setBackgroundColor(.gx_inputBackground, for: .highlighted)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.tintColor = .gx_gray
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 16.0
            $0.addTarget(self, action: #selector(self.searchButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var viewModel: GXConversationUsersListViewModel = {
        return GXConversationUsersListViewModel()
    }()

    /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
    required init(messageType: Int, activityId: Int? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.messageType = messageType
        self.viewModel.activityId = activityId
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.searchButton.imageLocationAdjust(model: .left, spacing: 4.0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.postNotificationRedPoint()
        if self.didGetNetworktLoad {
            self.requestRefreshData(isShowHud: false)
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
    }
    
    override func setupViewController() {
        if self.viewModel.activityId != nil {
            self.title = "消息"
            self.gx_addBackBarButtonItem()
        } else {
            self.tableView.tableHeaderView = self.searchView
        }
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.tableView.register(cellType: GXConversationCell.self)
        self.tableView.register(cellType: GXConversationPrzxCell.self)

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
}

extension GXConversationUsersListVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetListUserMessages(refresh: isRefresh, success: {[weak self] isLastPage in
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

    func requestMessageSetTop(indexPath: IndexPath) {
        let model = self.viewModel.list[indexPath.row]
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestMessageSetTop(chatId: model.id, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.requestRefreshData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestMessageDelete(indexPath: IndexPath, completion: GXActionBlock?) {
        let model = self.viewModel.list[indexPath.row]
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestMessageDelete(chatId: model.id, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.viewModel.list.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .left)
            completion?()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            completion?()
        })
    }
}

extension GXConversationUsersListVC: UISearchBarDelegate, UITextFieldDelegate {
    @objc func searchButtonClicked(_ sender: UIButton) {
        self.searchButton.hero.id = GXConversationUsersSearchVCHeroId
        let vc = GXConversationUsersSearchVC(messageType: self.viewModel.messageType)
        let navc = GXBaseNavigationController(rootViewController: vc)
        navc.hero.isEnabled = true
        navc.modalPresentationStyle = .fullScreen
        self.present(navc, animated: true)
    }
}

extension GXConversationUsersListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.viewModel.list[indexPath.row]
        if self.viewModel.messageType == 2 {
            let cell: GXConversationPrzxCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: model)
            return cell
        }
        else {
            let cell: GXConversationCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: model)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.viewModel.messageType == 2 {
            return 90.0
        }
        else {
            return 64.0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.viewModel.messageType == 2 {
            return UITableView.automaticDimension
        }
        else {
            return 64.0
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除", handler: { (action, view, completion) in
            GXUtil.showAlert(title: "确定删除此聊天？", actionTitle: "确定") { alert, index in
                guard index == 1 else {
                    completion(true); return
                }
                self.requestMessageDelete(indexPath: indexPath) {
                    completion(true)
                }
            }
        })
        let model = self.viewModel.list[indexPath.row]
        let settopTitle = (model.setTop == 1) ? "取消置顶":"置顶"
        let defaultAction = UIContextualAction(style: .normal, title: settopTitle, handler: { (action, view, completion) in
            completion(true)
            self.requestMessageSetTop(indexPath: indexPath)
        })
        defaultAction.backgroundColor = .gx_black
        return UISwipeActionsConfiguration(actions: [deleteAction, defaultAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        model.redPoint = false
        /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
        let vc = GXChatViewController(messageType: self.viewModel.messageType,
                                      chatId: model.id,
                                      activityId: model.activityId,
                                      title: model.activityName)
        let nav = GXBaseNavigationController(rootViewController: vc)
        self.gx_present(nav, style: .push) {[weak self] in
            self?.tableView.gx_reloadData()
            self?.viewModel.postNotificationRedPoint()
        }
    }

}
