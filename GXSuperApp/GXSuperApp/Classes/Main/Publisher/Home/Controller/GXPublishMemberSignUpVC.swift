//
//  GXPublishMemberSignUpVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/4.
//

import UIKit
import MBProgressHUD
import GXRefresh
import RxSwift

class GXPublishMemberSignUpVC: GXBaseViewController {
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var checkNumTitleLabel: UILabel!
    @IBOutlet weak var checkNumLabel: UILabel!

    @IBOutlet weak var searchIView: UIImageView!
    @IBOutlet weak var searchTField: UITextField!
    @IBOutlet weak var searchButton: UIButton!

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tableView: GXBaseTableView!
    weak var viewModel: GXPublishMemberViewModel!

    class func createVC(viewModel: GXPublishMemberViewModel) -> GXPublishMemberSignUpVC {
        return GXPublishMemberSignUpVC.xibViewController().then {
            $0.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetActivitySignInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.didGetNetworktLoad {
            self.requestGetActivitySignInfo()
        }
        self.didGetNetworktLoad = true
    }

    override func setupViewController() {
        self.submitButton.setBackgroundColor(.gx_green, for: .normal)

        let searchImage = UIImage(named: "pr_search_icon")?.withRenderingMode(.alwaysTemplate)
        self.searchIView.image = searchImage
        self.searchIView.tintColor = .gx_gray
        self.searchButton.setBackgroundColor(.gx_black, for: .normal)
        self.searchTField.delegate = self
        self.searchTField.rx.text.orEmpty.throttle(.milliseconds(300), scheduler: MainScheduler.instance).subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.searchTField.markedTextRange == nil else { return }
            self.viewModel.searchSigns(searchText: string)
            self.tableView.placeholder = (string.count > 0) ? "未搜索到报名用户":"暂无报名用户"
            self.tableView.gx_reloadData()
        }).disposed(by: disposeBag)

        self.tableView.placeholder = "暂无报名用户"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 68.0
        self.tableView.sectionHeaderHeight = 40.0
        self.tableView.register(headerFooterViewType: GXPublishMemberSignUpHeader.self)
        self.tableView.register(cellType: GXPublishMemberSignUpCell.self)

        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requestGetActivitySignInfo(isShowHud: false, completion: {
                self?.tableView.gx_header?.endRefreshing(isNoMore: true, isSucceed: true)
            })
        }).then({ header in
            header.updateRefreshTitles()
        })
    }

    func updateDataView() {
        // 活动模式 1-免费报名模式 2-卖票模式
        self.modeLabel.text = self.viewModel.activityData.activityMode == 2 ? "买票":"报名"
        self.checkNumTitleLabel.text = self.viewModel.activityData.activityMode == 2 ? "已付款":"已勾选"

        // 活动模式 1-免费报名模式 2-卖票模式
        if self.viewModel.activityData.activityMode == 2 {
            self.submitButton.isHidden = true
            self.tableView.setTableFooterView(height: 0.0)
        }
        else {
            self.tableView.setTableFooterView(height: 60.0)
            let signModel = self.viewModel.activityData.getSignUpModel()
            self.submitButton.isHidden = (signModel.canDateSignType == 2)
        }

        // 人数限制
        if self.viewModel.joinNum > 0 {
            self.limitLabel.text = "\(self.viewModel.joinNum)人"
        } else {
            self.limitLabel.text = "不限制"
        }

        self.viewModel.searchSigns(searchText: nil)
        self.updateSelected()
    }

    func updateSelected() {
        if self.viewModel.activityData.activityMode == 2 {
            if let data = self.viewModel.signInfoData?.activitySigns {
                self.checkNumLabel.text = "\(data.list.count)人"
            }
        }
        else {
            let selectArray = self.viewModel.searchSignList.filter{ $0.isChecked }
            self.checkNumLabel.text = "\(selectArray.count)人"
        }
        self.tableView.gx_reloadData()
    }
}
extension GXPublishMemberSignUpVC: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        self.viewModel.searchSigns(searchText: nil)
        self.tableView.gx_reloadData()
        return false
    }
}

extension GXPublishMemberSignUpVC {
    func requestGetActivitySignInfo(isShowHud: Bool = true, completion: (() -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetActivitySignInfo(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
            self?.updateDataView()
            completion?()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            completion?()
        })
    }

    func requestUpdateActivitySignInfo(signs: [GXActivitysignsItem]) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestUpdateActivitySignInfo(signs: signs, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "保存成功")
            self?.requestGetActivitySignInfo(isShowHud: false)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestVerifyActivitySignInfo(sign: GXActivitysignsItem) {
        self.viewModel.requestVerifyActivitySignInfo(activitySignId: sign.id, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.requestGetActivitySignInfo()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

}

extension GXPublishMemberSignUpVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.searchSignList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishMemberSignUpCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.searchSignList[indexPath.row]
        cell.bindCell(model: model, activityData: self.viewModel.activityData)
        cell.avatarAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            let userId = self.viewModel.searchSignList[curIndexPath.row].item.userId
            GXMinePtOtherVC.push(fromVC: self, userId: String(userId))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXPublishMemberSignUpHeader.self)
        let isAllSelected = self.viewModel.isAllSelected
        let isAllSelectHidden = self.submitButton.isHidden
        header?.bindView(activityData: self.viewModel.activityData, isAllSelected: isAllSelected, isAllSelectHidden: isAllSelectHidden)
        header?.allSelectAction = {[weak self] isAllSelected in
            self?.setSelectedCell(isAllSelected: isAllSelected)
        }
        return header
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.viewModel.activityData.activityMode == 1 {
            if !self.submitButton.isHidden {
                return indexPath
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.viewModel.searchSignList[indexPath.row]
        if self.viewModel.joinNum > 0 && !model.isChecked {
            let checkArr = self.viewModel.searchSignList.filter({ $0.isChecked })
            if checkArr.count >= self.viewModel.joinNum {
                GXToast.showSuccess(text: "已达到人数限制")
                return
            }
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? GXPublishMemberSignUpCell else { return }
        model.isChecked = !model.isChecked
        cell.isChecked = model.isChecked
        self.updateSelected()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let model = self.viewModel.searchSignList[indexPath.row]
        guard model.item.verifyFlag == 0 else { return false }
        guard GXRoleUtil.isTeller(roleType: self.viewModel.activityData.roleType) else { return false }

        return self.submitButton.isHidden
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: nil, handler: { (action, view, completion) in
            let model = self.viewModel.searchSignList[indexPath.row]
            GXUtil.showAlert(title: "确定核销票？", actionTitle: "确定") { alert, index in
                completion(true)
                guard index == 1 else { return }
                self.requestVerifyActivitySignInfo(sign: model.item)
            }
        })
        let editLabel = UILabel()
        editLabel.text = "核销票"
        editLabel.textColor = .gx_black
        editLabel.font = .gx_font(size: 15)
        editLabel.sizeToFit()
        editAction.image = UIImage.gx_createImage(view: editLabel)
        editAction.backgroundColor = .gx_green

        return UISwipeActionsConfiguration(actions: [editAction])
    }

}

extension GXPublishMemberSignUpVC {
    func setSelectedCell(isAllSelected: Bool) {
        if isAllSelected {
            if self.viewModel.joinNum > 0 {
                var count = self.viewModel.searchSignList.count
                count = min(self.viewModel.joinNum, count)
                for index in 0..<count {
                    let model = self.viewModel.searchSignList[index]
                    model.isChecked = true
                }
            }
            else {
                for model in self.viewModel.searchSignList {
                    model.isChecked = true
                }
            }
        }
        else {
            for model in self.viewModel.searchSignList {
                model.isChecked = false
            }
        }
        self.updateSelected()
    }

    @IBAction func submitButtonClicked(_ sender: UIButton) {
        guard GXRoleUtil.isTeller(roleType: self.viewModel.activityData.roleType) else {
            GXToast.showError(text: "权限不足")
            return
        }
        var selectItems: [GXActivitysignsItem] = []
        for model in self.viewModel.searchSignList {
            guard model.isChecked else { continue }
            selectItems.append(model.item)
        }
        guard selectItems.count > 0 else {
            GXToast.showError(text: "请先勾选报名用户")
            return
        }
        self.requestUpdateActivitySignInfo(signs: selectItems)
    }
}
