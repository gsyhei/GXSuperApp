//
//  GXChatViewController.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/21.
//

import UIKit
import HXPhotoPicker
import MBProgressHUD

class GXChatViewController: GXBaseChatViewController {

    private lazy var viewModel: GXChatViewModel = {
        return GXChatViewModel()
    }()

    private lazy var header: GXChatGroupMemberHeader = {
        return GXChatGroupMemberHeader.xibView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 170))
            $0.bindHeaderView(viewModel: self.viewModel)
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }()

    private var isShowGroupHeader: Bool {
        return (self.viewModel.messageType == 3 || self.viewModel.messageType == 4)
    }

    deinit {
        NSLog("GXChatViewController deinit")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.viewModel.messageType == 1 || self.viewModel.messageType == 2 {
            return .default
        } else {
            return .lightContent
        }
    }

    /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
    init(messageType: Int, chatId: Int = 0, activityId: Int, title: String?) {
        super.init(nibName: String(describing: GXBaseChatViewController.self), bundle: nil)

        self.viewModel.messageType = messageType
        self.viewModel.activityId = activityId
        self.viewModel.chatId = chatId
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetCAChatActivityChatInfo()
        self.requestActivityUsers()
        self.requestGetActivityBaseInfo()
    }
    
    override func setupViewController() {
        super.setupViewController()

        self.tableView.register(cellType: GXMessagesLeftCell.self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableHeaderView = UIView()
        if self.viewModel.messageType == 1 || self.viewModel.messageType == 2 {
            self.tableView.placeholder = "暂无咨询"
            self.setThemeType(type: 1)
        }
        else {
            self.tableView.placeholder = "暂无消息"
            self.setThemeType(type: 0)
        }
    }
    
    override func sendMessage(text: String, photoAssets: [PhotoAsset]) {
        self.requestCAChatCreateActivityChat(text: text, photoAssets: photoAssets)
    }
}

extension GXChatViewController {
    @objc func requestGetCAChatActivityChatInfo(isShowHud: Bool = true) {
        if isShowHud {
            let ballColor: UIColor = (self.themeType == 1) ? .gx_black:.white
            MBProgressHUD.showLoading(ballColor: ballColor, to: self.view)
        }
        self.viewModel.requestGetChatList(success: {[weak self] isUpdate in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            if isUpdate {
                self.tableView.gx_reloadData()
                if isShowHud {
                    self.view.layoutIfNeeded()
                    self.scrollToBottom(animated: false)
                }
            }
            self.nextPerformGetChatInfo()
        }, failure: {[weak self] error in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            if isShowHud {
                GXToast.showError(error, to: self.view)
            }
            self.nextPerformGetChatInfo()
        })
    }
    func requestActivityUsers() {
        let ballColor: UIColor = (self.themeType == 1) ? .gx_black:.white
        MBProgressHUD.showLoading(ballColor: ballColor, to: self.view)
        self.viewModel.requestActivityUsers(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            if self.isShowGroupHeader {
                self.setGroupTableHeaderView()
            } else if self.viewModel.data != nil {
                self.tableView.gx_reloadData()
            }
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    func requestCAChatCreateActivityChat(text: String, photoAssets: [PhotoAsset]) {
        let ballColor: UIColor = (self.themeType == 1) ? .gx_black:.white
        MBProgressHUD.showLoading(ballColor: ballColor, to: self.view)
        self.viewModel.requestChatSendUpload(text: text, photoAssets: photoAssets, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.clearMessage()
            self?.tableView.gx_reloadData()
            self?.scrollToBottom(animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            if error.localizedDescription.contains(find: "内容包含敏感词") {
                GXToast.showError(text: "发送失败，内容包含敏感词语", to: self?.view)
            } else {
                GXToast.showError(error, to: self?.view)
            }
        })
    }

    func requestGetActivityBaseInfo() {
        guard self.title?.isEmpty ?? true else { return }
        self.viewModel.requestGetActivityBaseInfo {[weak self] data in
            self?.title = data?.activityName
        } failure: { error in }
    }
}

extension GXChatViewController {
    func nextPerformGetChatInfo() {
        self.perform(#selector(self.requestGetCAChatActivityChatInfo), with: false, afterDelay: 5.0)
    }
    func setGroupTableHeaderView() {
        self.header.bindHeaderView(viewModel: self.viewModel)
        self.header.userAction = {[weak self] user in
            guard let `self` = self else { return }
            if let letUser = user {
                let vc = GXMinePtOtherVC(userId: String(letUser.userId))
                let nav = GXBaseNavigationController(rootViewController: vc)
                self.gx_present(nav, style: .push)
            }
            else {
                let vc = GXChatGroupMemberVC.createVC(messageType: self.viewModel.messageType,
                                                      chatId: self.viewModel.chatId,
                                                      title: self.title)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        self.tableView.gx_reloadData()
    }
    func showImageBrowser(cell: GXMessagesLeftCell, indexPath: IndexPath) {
        guard let image = cell.chatImageView.image else { return }

        HXPhotoPicker.PhotoBrowser.show(pageIndex: 0, transitionalImage: image) {
            return 1
        } assetForIndex: {_ in
            let cell = self.tableView.cellForRow(at: indexPath) as? GXMessagesLeftCell
            return PhotoAsset(LocalImageAsset(image: cell?.chatImageView.image ?? UIImage()))
        } transitionAnimator: { index in
            let cell = self.tableView.cellForRow(at: indexPath) as? GXMessagesLeftCell
            return cell?.chatImageView
        }
    }
}

extension GXChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.viewModel.data else { return 0 }

        return data.children.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = self.viewModel.data else { return UITableViewCell() }
        var item: GXListUserMessagesItem?
        if indexPath.row == 0 {
            item = data
        } else {
            let row = indexPath.row - 1
            if data.children.count > row {
                item = data.children[indexPath.row - 1]
            }
        }
        let cell: GXMessagesLeftCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setThemeType(type: self.themeType)
        cell.bindCell(model: item, staffsUserIds: self.viewModel.staffsUserIds)
        cell.avatarAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            var curItem: GXListUserMessagesItem?
            if curIndexPath.row == 0 {
                curItem = self.viewModel.data
            } else {
                curItem =  self.viewModel.data?.children[curIndexPath.row - 1]
            }
            guard let userId = curItem?.userId else { return }
            let vc = GXMinePtOtherVC(userId: String(userId))
            let nav = GXBaseNavigationController(rootViewController: vc)
            self.gx_present(nav, style: .push)
        }
        cell.imageAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            self.showImageBrowser(cell: curCell, indexPath: curIndexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let data = self.viewModel.data else { return .zero }
        var item: GXListUserMessagesItem?
        if indexPath.row == 0 {
            item = data
        } else {
            item = data.children[indexPath.row - 1]
        }
        return GXMessagesLeftCell.height(view: tableView, model: item)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.isShowGroupHeader ? self.header.frame.height : .zero
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.isShowGroupHeader ? self.header : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
