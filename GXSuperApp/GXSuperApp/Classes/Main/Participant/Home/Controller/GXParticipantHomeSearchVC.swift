//
//  GXParticipantHomeSearchVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import XCGLogger
import RxCocoa
import RxCocoaPlus
import MBProgressHUD
import GXRefresh

let GXParticipantHomeSearchVCHeroId = "search"
class GXParticipantHomeSearchVC: GXBaseViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var searchTableView: GXBaseTableView!
    var selectedAction: GXActionBlockItem<GXCalendarActivityItem>?

    private lazy var viewModel: GXParticipantHomeSearchViewModel = {
        return GXParticipantHomeSearchViewModel()
    }()

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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.hero.id = GXParticipantHomeSearchVCHeroId
        self.requestGetListHotSearch()
    }

    override func setupViewController() {

        self.searchTextField.delegate = self
        self.searchTextField.rx.text.orEmpty.subscribe (onNext: {[weak self] text in
            if text.count == 0 {
                self?.searchTableView.isHidden = false
                self?.tableView.isHidden = true
                self?.searchTableView.gx_reloadData()
            }
        }).disposed(by: disposeBag)
        (self.searchTextField.rx.textInput <-> self.viewModel.searchWord).disposed(by: disposeBag)

        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        self.searchTableView.separatorColor = .gx_lightGray
        self.searchTableView.register(headerFooterViewType: GXPrHomeSearchHeader.self)
        self.searchTableView.register(cellType: GXPrHomeSearchHistoryCell.self)
        self.searchTableView.register(cellType: GXPrHomeSearchHotCell.self)
        self.searchTableView.gx_reloadData()

        self.tableView.isHidden = true
        self.tableView.placeholder = "暂无搜索的活动"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorColor = .gx_lightGray
        self.tableView.register(cellType: GXPrCalendarActivityPageCell.self)
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

extension GXParticipantHomeSearchVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetSearchActivity(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self?.view)
            self?.searchTableView.isHidden = true
            self?.tableView.isHidden = false
            self?.tableView.gx_reloadData()
            self?.tableView.layoutIfNeeded()
            completion?(true, isLastPage)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            completion?(false, false)
        })
    }

    func requestRefreshData() {
        self.view.endEditing(true)
        GXUserManager.addSearchHistory(self.viewModel.searchWord.value)
        self.requestData(isRefresh: true, isShowHud: true) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }

    func requestGetListHotSearch() {
        if GXActivityManager.shared.hotSearchList.count > 0 {
            self.searchTableView.gx_reloadData()
            return
        }
        MBProgressHUD.showLoading(to: self.view)
        GXActivityManager.shared.requestGetListHotSearch {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.searchTableView.gx_reloadData()
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }

    func deleteHistoryShowAlert() {
        guard GXUserManager.shared.searchHistory?.count ?? 0 > 0 else { return }
        let title = "确定要删除历史搜索记录吗？"
        GXUtil.showAlert(title: title, actionTitle: "删除", actionStyle: .destructive) { alert, index in
            guard index == 1 else { return }
            GXUserManager.updateSearchHistory(nil)
            self.searchTableView.gx_reloadData()
        }
    }
}

extension GXParticipantHomeSearchVC {
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension GXParticipantHomeSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard self.viewModel.searchWord.value?.count ?? 0 > 0 else {
            return true
        }
        self.requestRefreshData()
        return true
    }
}

extension GXParticipantHomeSearchVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return 1
        }
        else {
            return 2
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.viewModel.list.count
        }
        else {
            if section == 0 {
                return 1
            }
            else {
                return GXActivityManager.shared.hotSearchList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell: GXPrCalendarActivityPageCell = tableView.dequeueReusableCell(for: indexPath)
            let model = self.viewModel.list[indexPath.row]
            cell.bindCell(model: model)
            return cell
        }
        else {
            if indexPath.section == 0 {
                let cell: GXPrHomeSearchHistoryCell = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell(list: GXUserManager.shared.searchHistory ?? [])
                cell.selectedAction = {[weak self] title in
                    self?.viewModel.searchWord.accept(title)
                    self?.requestRefreshData()
                }
                return cell
            }
            else {
                let cell: GXPrHomeSearchHotCell = tableView.dequeueReusableCell(for: indexPath)
                let title = GXActivityManager.shared.hotSearchList[indexPath.row]
                cell.bindCell(title: title, index: indexPath.row)
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            return nil
        }
        else {
            let header = tableView.dequeueReusableHeaderFooterView(GXPrHomeSearchHeader.self)
            if section == 0 {
                header?.bindView(title: "历史搜索", isDelete: true)
                header?.deleteAction = {[weak self] in
                    self?.deleteHistoryShowAlert()
                }
            }
            else {
                header?.bindView(title: "热门搜索", image: UIImage(named: "pr_hot_icon"))
            }
            return header
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return .zero
        }
        return 42.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 170.0
        }
        else {
            if indexPath.section == 0 {
                return SCREEN_HEIGHT
            }
            else {
                return .zero
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 170.0
        }
        else {
            if indexPath.section == 0 {
                return UITableView.automaticDimension
            }
            else {
                return 44.0
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tableView {
            let model = self.viewModel.list[indexPath.row]
            let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.hero.isEnabled = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            guard indexPath.section == 1 else { return }
            let title = GXActivityManager.shared.hotSearchList[indexPath.row]
            self.viewModel.searchWord.accept(title)
            self.requestRefreshData()
        }
    }
}


