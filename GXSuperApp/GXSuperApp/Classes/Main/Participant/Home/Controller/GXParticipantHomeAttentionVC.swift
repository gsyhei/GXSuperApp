//
//  GXParticipantHomeAttentionVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/5.
//

import UIKit
import MBProgressHUD
import GXRefresh

class GXParticipantHomeAttentionVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!

    private var viewModel: GXParticipantHomeAttentionViewModel = {
        return GXParticipantHomeAttentionViewModel()
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !self.didGetNetworktLoad {
            if self.viewModel.isFollow {
                self.requestGetListMayBeInterested()
            }
            else {
                self.requestRefreshData()
            }
        }
        self.didGetNetworktLoad = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        if self.viewModel.isFollow {
            self.tableView.rowHeight = 88.0
            self.tableView.register(cellType: GXMinePtAddFansPageCell.self)
            let headerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 40))).then {
                let imageView = UIImageView(image: UIImage(named: "pt_follow_top"))
                $0.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview().offset(12)
                    make.size.equalTo(CGSize(width: 218, height: 40))
                }
            }
            self.tableView.tableHeaderView = headerView
        }
        else {
            self.tableView.rowHeight = 238.0
            self.tableView.sectionHeaderHeight = .leastNonzeroMagnitude
            self.tableView.register(cellType: GXPrHomeFollowActivityCell.self)
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
}

extension GXParticipantHomeAttentionVC {
    func requestGetListMayBeInterested() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetListMayBeInterested {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.reloadData()
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }

    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGeFollowActivity(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.reloadData()
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

    func requestFollowUser(index: Int) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestFollowUser(index: index, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestFollowUsers() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestFollowUsers(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func showFollowUsers() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            GXUtil.showAlert(title: "是否一键关注所有您可能敢兴趣的人？", actionTitle: "确定") { alert, index in
                guard index == 1 else { return }
                self.requestFollowUsers()
            }
        }
    }
}

extension GXParticipantHomeAttentionVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.viewModel.isFollow else{ return }
        guard let pageCell = cell as? GXMinePtAddFansPageCell else { return }
        GXBaseTableView.setFollowTableView(tableView, roundView: pageCell.containerView, at: indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.isFollow {
            return self.viewModel.userList.count
        }
        else {
            return self.viewModel.activityList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.viewModel.isFollow {
            let cell: GXMinePtAddFansPageCell = tableView.dequeueReusableCell(for: indexPath)
            let model = self.viewModel.userList[indexPath.row]
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.bindCell(model: model)
            cell.attentionAction = {[weak self] curCell in
                self?.attentionAction(cell: curCell)
            }
            return cell
        }
        else {
            let cell: GXPrHomeFollowActivityCell = tableView.dequeueReusableCell(for: indexPath)
            let model = self.viewModel.activityList[indexPath.row]
            cell.bindCell(model: model)
            cell.avatarAction = {[weak self] curCell in
                guard let `self` = self else { return }
                guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
                let userId = self.viewModel.activityList[curIndexPath.row].creatorId
                GXMinePtOtherVC.push(fromVC: self, userId: userId)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.viewModel.isFollow {
            let model = self.viewModel.userList[indexPath.row]
            GXMinePtOtherVC.push(fromVC: self, userId: model.id)
        }
        else {
            let model = self.viewModel.activityList[indexPath.row]
            let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func attentionAction(cell: GXMinePtAddFansPageCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let model = self.viewModel.userList[indexPath.row]

        if model.followEachOther {
            GXUtil.showAlert(title: "确认不再关注？", actionTitle: "确定") { alert, index in
                guard index == 1 else { return }
                self.requestFollowUser(index: indexPath.row)
            }
        } else {
            self.requestFollowUser(index: indexPath.row)
        }
    }
}

