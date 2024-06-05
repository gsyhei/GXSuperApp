//
//  GXPublishMemberWorkerVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/4.
//

import UIKit
import MBProgressHUD
import GXRefresh

class GXPublishMemberWorkerVC: GXBaseViewController {
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var tableView: GXBaseTableView!
    weak var viewModel: GXPublishMemberViewModel!

    class func createVC(viewModel: GXPublishMemberViewModel) -> GXPublishMemberWorkerVC {
        return GXPublishMemberWorkerVC.xibViewController().then {
            $0.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
    }

    override func setupViewController() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 104.0
        self.tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        self.tableView.register(cellType: GXPublishMemberWorkerCell.self)
        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requestData(isRefresh: true, isShowHud: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_header?.endRefreshing(isNoMore: isLastPage, isSucceed: isSucceed)
            })
        }).then({ header in
            header.updateRefreshTitles()
        })
    }

    func updateDataView() {
        if let infoData = self.viewModel.workerInfoData {
            self.modeLabel.text = infoData.activityMode == 2 ? "卖票":"报名"
            if infoData.limitJoinNum == 1 {
                self.limitLabel.text = "\(infoData.joinNum)人"
            } else {
                self.limitLabel.text = "不限制"
            }
        }
        else if let infoData = self.viewModel.signInfoData {
            self.modeLabel.text = infoData.activityMode == 2 ? "卖票":"报名"
            if infoData.limitJoinNum == 1 {
                self.limitLabel.text = "\(infoData.joinNum)人"
            } else {
                self.limitLabel.text = "不限制"
            }
        }
        else {
            self.modeLabel.text = self.viewModel.activityData.activityMode == 2 ? "卖票":"报名"
            self.limitLabel.text = "0人"
        }
        if GXRoleUtil.isOneAdmin(roleType: self.viewModel.activityData.roleType) {
            self.viewModel.isMeAdmin = true
        }
        else {
            if self.viewModel.workerList.first(where: { GXRoleUtil.isOneAdmin(roleType: $0.roleType)}) != nil {
                self.viewModel.isMeAdmin = false
            } else {
                self.viewModel.isMeAdmin = true
            }
        }
        self.tableView.reloadData()
    }
}

extension GXPublishMemberWorkerVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetActivityStaffs(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateDataView()
            completion?(true, true)
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

    func requestUpdateActivityStaffInfo(staffs: [GXActivitystaffsModel]) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestUpdateActivityStaffInfo(staffs: staffs, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateActivityStaffs(staffs: staffs)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func updateActivityStaffs(staffs: [GXActivitystaffsModel]) {
        self.viewModel.workerList = staffs
        if self.viewModel.workerList.first(where: { GXRoleUtil.isOneAdmin(roleType: $0.roleType)}) != nil {
            self.viewModel.isMeAdmin = false
        } else {
            self.viewModel.isMeAdmin = true
        }
        self.tableView.reloadData()

        guard let user = GXUserManager.shared.user else { return }
        guard let staffItem = staffs.first(where: {$0.userId == user.id}) else { return }
        self.viewModel.activityData.roleType = staffItem.roleType
    }
}

extension GXPublishMemberWorkerVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.workerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishMemberWorkerCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.workerList[indexPath.row]
        cell.bindCell(model: model, myRoleType: self.viewModel.activityData.roleType, isMeAdmin: self.viewModel.isMeAdmin)
        cell.avatarAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            let userId = self.viewModel.workerList[curIndexPath.row].userId
            GXMinePtOtherVC.push(fromVC: self, userId: String(userId))
        }
        cell.buttonAction = {[weak self] (curCell, title) in
            self?.workerCellButtonAction(cell: curCell, title: title)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension GXPublishMemberWorkerVC {

    func workerCellButtonAction(cell: GXPublishMemberWorkerCell, title: String) {
        if !GXRoleUtil.isAdmin(roleType: self.viewModel.activityData.roleType) {
            GXToast.showError(text: "权限不足"); return
        }
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }

        var activityStaffs: [GXActivitystaffsModel] = []
        for item in self.viewModel.workerList {
            let copyItem = item.gx_copy()
            activityStaffs.append(copyItem)
        }
        let model = activityStaffs[indexPath.row]
        // 角色类型 1-发布者 2-管理员 3-核销票 4-客服
        switch title {
        case "移除": 
            let title = "确定移除工作人员[\(model.nickName)]吗？"
            GXUtil.showAlert(title: title, actionTitle: "确定") { alert, index in
                guard index == 1 else { return }
                activityStaffs.remove(at: indexPath.row)
                self.requestUpdateActivityStaffInfo(staffs: activityStaffs)
            }
        case "移交为管理员":
            let title = "确定把管理员权利移交给[\(model.nickName)]吗？"
            GXUtil.showAlert(title: title, actionTitle: "确定") { alert, index in
                guard index == 1 else { return }
                for item in activityStaffs {
                    if GXRoleUtil.isOneAdmin(roleType: item.roleType) {
                        item.roleType = GXRoleUtil.remove(old: item.roleType, type: "2")
                    }
                }
                model.roleType = GXRoleUtil.append(old: model.roleType, type: "2")
                self.requestUpdateActivityStaffInfo(staffs: activityStaffs)
            }
        case "增加核销票":
            model.roleType = GXRoleUtil.append(old: model.roleType, type: "3")
            self.requestUpdateActivityStaffInfo(staffs: activityStaffs)
            break
        case "取消核销票": 
            model.roleType = GXRoleUtil.remove(old: model.roleType, type: "3")
            self.requestUpdateActivityStaffInfo(staffs: activityStaffs)
            break
        case "增加客服": 
            model.roleType = GXRoleUtil.append(old: model.roleType, type: "4")
            self.requestUpdateActivityStaffInfo(staffs: activityStaffs)
        case "取消客服":
            model.roleType = GXRoleUtil.remove(old: model.roleType, type: "4")
            self.requestUpdateActivityStaffInfo(staffs: activityStaffs)
        default: break
        }
    }



}
