//
//  GXConversationUsersSearchVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit
import RxCocoaPlus
import MBProgressHUD
import GXRefresh

let GXConversationUsersSearchVCHeroId = "search"
class GXConversationUsersSearchVC: GXBaseViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: GXBaseTableView!

    private lazy var viewModel: GXConversationUsersSearchViewModel = {
        return GXConversationUsersSearchViewModel()
    }()

    /// 消息tab 1-活动咨询(参与端) 2-活动咨询(发布端) 3-报名群(参与端) 4-报名群(发布端) 5-工作群(发布端)
    required init(messageType: Int) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.messageType = messageType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.hero.isEnabled = true
        if !self.didGetNetworktLoad {
            self.searchTextField.becomeFirstResponder()
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.hero.id = GXConversationUsersSearchVCHeroId
    }

    override func setupViewController() {

        self.searchTextField.delegate = self
        (self.searchTextField.rx.textInput <-> self.viewModel.searchWord).disposed(by: disposeBag)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        self.tableView.rowHeight = 148.0
        self.tableView.placeholder = "暂无搜索的活动"
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

extension GXConversationUsersSearchVC {
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
    func requestRefreshData() {
        self.requestData(isRefresh: true, isShowHud: true) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }
}

extension GXConversationUsersSearchVC {
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.searchTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
}

extension GXConversationUsersSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard self.viewModel.searchWord.value?.count ?? 0 > 0 else {
            return true
        }
        self.requestRefreshData()
        return true
    }
}

extension GXConversationUsersSearchVC: UITableViewDataSource, UITableViewDelegate {
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
            return .zero
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
        self.gx_present(nav, style: .push)
    }

}
