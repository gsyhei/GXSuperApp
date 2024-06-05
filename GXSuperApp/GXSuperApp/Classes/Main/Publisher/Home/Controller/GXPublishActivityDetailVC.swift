//
//  GXPublishActivityDetailVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/11.
//

import UIKit
import MBProgressHUD
import GXSegmentPageView
import HXPhotoPicker
import Kingfisher

class GXPublishActivityDetailVC: GXBaseWarnViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var optionBarView: UIView!
    @IBOutlet weak var signUpGroupButton: UIButton!
    @IBOutlet weak var consultButton: UIButton!
    @IBOutlet weak var workGroupButton: UIButton!
    @IBOutlet weak var addedButton: UIButton!
    @IBOutlet weak var edidButton: UIButton!
    var deleteAction: GXActionBlockItem<Int>?

    weak var segmentTitleView: GXSegmentTitleView?
    var beginDragging: Bool = false

    private lazy var viewModel: GXPublishActivityDetailViewModel = {
        return GXPublishActivityDetailViewModel()
    }()

    class func createVC(activityId: Int) -> GXPublishActivityDetailVC {
        return GXPublishActivityDetailVC.xibViewController().then {
            $0.viewModel.activityId = activityId
            $0.hidesBottomBarWhenPushed = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.signUpGroupButton.imageLocationAdjust(model: .top, spacing: 2)
        self.consultButton.imageLocationAdjust(model: .top, spacing: 2)
        self.workGroupButton.imageLocationAdjust(model: .top, spacing: 2)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.didGetNetworktLoad {
            self.requestGetActivitInfo(isShowHud: false)
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.requestGetActivitInfo()
        GXLocationManager.shared.requestGeocodeCompletion {[weak self] (isAuth, cityName, location) in
            self?.tableView.reloadData()
        }
    }

    override func setupViewController() {
        self.gx_addBackBarButtonItem()

        self.addedButton.setBackgroundColor(.gx_green, for: .normal)
        self.addedButton.setBackgroundColor(.gx_lightGray, for: .disabled)
        self.edidButton.setBackgroundColor(.gx_black, for: .normal)
        self.optionBarView.isHidden = true

        self.tableView.setTableFooterView(height: 8.0)
        self.tableView.register(cellType: GXPublishActivityDetailCell.self)
        self.tableView.register(cellType: GXPublishActivityDetailPicCell.self)
        self.tableView.register(cellType: GXPublishActivityDetailUserCell.self)
        self.tableView.register(cellType: GXPublishActivityDetailSecCell.self)
        self.tableView.register(cellType: GXActivityDetailTextCell.self)
        self.tableView.register(headerFooterViewType: GXPublishActivityDetailTabHeader.self)
    }

    func updateTopView() {
        guard let info =  self.viewModel.infoData else { return }
        self.optionBarView.isHidden = false

        /// 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过
        if info.activityStatus > 1 && info.activityStatus < 5 {
            // 审核通过
            if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ah_more_icon"), style: .plain, target: self, action: #selector(self.rightButtonItemTapped))
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }

        /// 上下架状态 1-上架中 0-下架中 2-平台禁用
        if info.shelfStatus == 0 {
            self.addedButton.isHidden = true
            self.edidButton.setTitle("管理", for: .normal)
        }
        else if info.shelfStatus == 1 {
            self.addedButton.isHidden = false
            self.addedButton.isEnabled = true
            self.addedButton.setTitle("下架", for: .normal)
            self.edidButton.setTitle("编辑", for: .normal)
        }
        else {
            self.addedButton.isHidden = false
            self.addedButton.isEnabled = false
            self.addedButton.setTitle("上架", for: .normal)
            self.edidButton.setTitle("编辑", for: .normal)
        }

        if !GXRoleUtil.isAdmin(roleType: info.roleType) {
            self.addedButton.gx_setDisabledButton()
            self.edidButton.gx_setDisabledButton()
        }
        if info.activityStatus == 5 {
            let text = "审核未通过\n原因：\(info.rejectReason)"
            self.gx_showWarning(text: text)
        }
        else {
            self.gx_hideWarning()
        }
    }

}

extension GXPublishActivityDetailVC {
    func requestGetActivitInfo(isShowHud: Bool = true) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetActivityAllInfo(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.updateTopView()
            self.tableView.gx_reloadData()
            self.scrollViewDidScroll(self.tableView)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestSetShelfStatus() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSetShelfStatus(success: {[weak self] shelfStatus in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateTopView()
            let text = (shelfStatus == 1) ? "已上架":"已下架"
            GXToast.showSuccess(text: text, to: self?.view)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestActivityDelete() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestActivityDelete(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "活动已删除")
            self.deleteAction?(self.viewModel.activityId)
            self.navigationController?.popViewController(animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error)
        })
    }

}

extension GXPublishActivityDetailVC: UITableViewDataSource, UITableViewDelegate {

    func section1RowCount() -> Int {
        let closeCount = self.viewModel.descAssets.count > 0 ? 1:0
        return self.viewModel.isOpenDetail ? (self.viewModel.descAssets.count + 2) : closeCount + 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + self.viewModel.bottomTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.section1RowCount()
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return GXPublishActivityDetailCell.height(data: self.viewModel.infoData)
        }
        else if indexPath.section == 1 {
            if self.viewModel.isOpenDetail {
                if indexPath.row == self.section1RowCount() - 2 {
                    if let data = self.viewModel.activityRuleInfoData {
                        let height = data.compositeText().height(width: tableView.width - 32.0)
                        return ceil(height) + 16.0
                    }
                    return 0
                }
                else if indexPath.row == self.section1RowCount() - 1 {
                    return 148.0
                }
            }
            else {
                if indexPath.row == self.section1RowCount() - 1 {
                    return 148.0
                }
            }
            return GXPublishActivityDetailPicCell.height(asset: self.viewModel.descAssets[indexPath.row])
        }
        return 56.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 54
        }
        return .zero
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: GXPublishActivityDetailCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindModel(data: self.viewModel.infoData, topAssets: self.viewModel.topAssets, isShowCMapBtn: true)
            cell.locationAction = {[weak self] in
                guard let `self` = self else { return }
                guard let data = self.viewModel.infoData else { return }
//                let vc = GXActivityMapVC(data: data)
//                self.navigationController?.pushViewController(vc, animated: true)
                let coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
                XYNavigationManager.show(with: self, coordinate: coordinate, endAddress: data.address)
            }
            cell.ruleAction = {
                let vc = GXPublishRuleDescVC.xibViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }

            return cell
        }
        else if indexPath.section == 1 {
            if self.viewModel.isOpenDetail {
                if indexPath.row == self.section1RowCount() - 2 {
                    let cell: GXActivityDetailTextCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.bindCell(model: self.viewModel.activityRuleInfoData)
                    return cell
                }
                else if indexPath.row == self.section1RowCount() - 1 {
                    let cell: GXPublishActivityDetailUserCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.bindModel(data: self.viewModel.infoData, isOpen: self.viewModel.isOpenDetail)
                    cell.openAction = {[weak self] isOpen in
                        guard let `self` = self else { return }
                        self.viewModel.isOpenDetail = isOpen
                        self.tableView.reloadData()
                        self.scrollViewDidScroll(self.tableView)
                    }
                    return cell
                }
            }
            else {
                if indexPath.row == self.section1RowCount() - 1 {
                    let cell: GXPublishActivityDetailUserCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.bindModel(data: self.viewModel.infoData, isOpen: self.viewModel.isOpenDetail)
                    cell.openAction = {[weak self] isOpen in
                        guard let `self` = self else { return }
                        self.viewModel.isOpenDetail = isOpen
                        self.tableView.reloadData()
                        self.scrollViewDidScroll(self.tableView)
                    }
                    return cell
                }
            }
            let cell: GXPublishActivityDetailPicCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindModel(asset: self.viewModel.descAssets[indexPath.row]) {[weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }

            return cell
        }
        else {
            let cell: GXPublishActivityDetailSecCell = tableView.dequeueReusableCell(for: indexPath)
            let title = self.viewModel.bottomTitles[indexPath.section - 2]
            cell.titleLabel.text = title

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = tableView.dequeueReusableHeaderFooterView(GXPublishActivityDetailTabHeader.self)
            header?.segmentTitleView.delegate = self
            self.segmentTitleView = header?.segmentTitleView

            return header
        }
        return nil
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.beginDragging = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.beginDragging else { return }
        guard let lastVisibleCell = self.tableView.visibleCells.last else { return }
        guard let indexPath = self.tableView.indexPath(for: lastVisibleCell) else { return }
        let index = indexPath.section - 1
        if index > 0 {
            self.segmentTitleView?.setSelectIndex(at: index, animated: false)
        }
        else {
            self.segmentTitleView?.setSelectIndex(at: 0, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? GXPublishActivityDetailPicCell {
                HXPhotoPicker.PhotoBrowser.show(pageIndex: indexPath.row, transitionalImage: cell.picImageView.image) {
                    self.viewModel.descAssets.count
                } assetForIndex: {
                    self.viewModel.descAssets[$0]
                } transitionAnimator: { index in
                    let curIndexPath = IndexPath(row: index, section: indexPath.section)
                    let cell = tableView.cellForRow(at: curIndexPath) as? GXPublishActivityDetailPicCell
                    return cell?.picImageView
                }
            }
            else if tableView.cellForRow(at: indexPath) is GXPublishActivityDetailUserCell {
                if let userId = self.viewModel.infoData?.creatorId {
                    GXMinePtOtherVC.push(fromVC: self, userId: userId)
                }
            }
        }
        else if indexPath.section > 1 {
            guard let activityData = self.viewModel.infoData else { return }
            switch indexPath.section {
            case 2: // 场地图
                let vc = GXPublishActivityDetailMapVC.createVC(activityData: activityData)
                self.navigationController?.pushViewController(vc, animated: true)
            case 3: // 成员
                let vc = GXPublishMemberVC.createVC(activityData: activityData)
                self.navigationController?.pushViewController(vc, animated: true)
            case 4: // 问卷调查
                let vc = GXPublishQuestionnaireVC.createVC(activityData: activityData)
                self.navigationController?.pushViewController(vc, animated: true)
            case 5: // 事件活动
                let vc = GXPublishEventListVC(activityData: activityData)
                self.navigationController?.pushViewController(vc, animated: true)
            case 6: // 回顾
                let vc = GXPublishReviewVC.createVC(activityId: self.viewModel.activityId, roleType: activityData.roleType)
                self.navigationController?.pushViewController(vc, animated: true)
            case 7: // 财务
                let vc = GXPublishFinancialVC.createVC(activityData: activityData)
                self.navigationController?.pushViewController(vc, animated: true)
            case 8: // 汇报
                let vc = GXPublishWorkReportVC(activityId: self.viewModel.activityId)
                self.navigationController?.pushViewController(vc, animated: true)
            default: break
            }
        }
    }
}

extension GXPublishActivityDetailVC: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        var section: Int = 0
        if index == 0 {
            section = 0
        } else {
            section = index + 1
        }
        self.tableView.scrollToRow(row: 0, section: section, scrollPosition: .bottom, animated: true)
    }
}

extension GXPublishActivityDetailVC {

    @objc func rightButtonItemTapped() {
        self.showAlertRightItem()
    }
    @IBAction func signUpGroupButtonClicked(_ sender: UIButton) {
        guard let activityData = self.viewModel.infoData else { return }
        // 报名群
        let vc = GXChatViewController(messageType: 4,
                                      activityId: activityData.id,
                                      title: activityData.activityName)
        let nav = GXBaseNavigationController(rootViewController: vc)
        self.gx_present(nav, style: .push)
    }
    @IBAction func consultButtonClicked(_ sender: UIButton) {
        // 活动咨询
        let vc = GXConversationUsersListVC(messageType: 2, activityId: self.viewModel.activityId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func workGroupButtonClicked(_ sender: UIButton) {
        guard let activityData = self.viewModel.infoData else { return }
        // 工作群
        let vc = GXChatViewController(messageType: 5,
                                      activityId: activityData.id,
                                      title: activityData.activityName)
        let nav = GXBaseNavigationController(rootViewController: vc)
        self.gx_present(nav, style: .push)
    }
    @IBAction func addedButtonClicked(_ sender: UIButton) {
        // 上架/下架
        self.requestSetShelfStatus()
    }
    @IBAction func edidButtonClicked(_ sender: UIButton) {
        if sender.title(for: .normal) == "管理" {
            self.showAlertManagerActivity()
            return
        }
        self.gotoEditActivity()
    }

    func gotoEditActivity() {
        guard let info = self.viewModel.infoData else { return }
        if info.activityStatus == 1 {
            GXToast.showError(text: "平台审核中，无法编辑")
            return
        }
        if info.activityStatus == 4 {
            GXToast.showError(text: "活动已结束，无法编辑")
            return
        }
//        if info.signedNum > 0 {
//            GXToast.showError(text: "有人已经报名，无法编辑")
//            return
//        }
        /// 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过
        if info.activityStatus == 2 || info.activityStatus == 3 {
            let title = "您重新提交，平台需要再次审核\n核通过后，用户才可报名\n已报名用户请线下通知\n报名模式，如果有人已经报名，则无法修改"
            GXUtil.showAlert(title: title, actionTitle: "知道了,继续编辑") { alert, index in
                if index == 1 {
                    let vc = GXPublishStep1VC.createVC(type: .detail,
                                                       activityId: self.viewModel.activityId,
                                                       infoData: self.viewModel.infoData,
                                                       picData: self.viewModel.picData)
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else {
            let vc = GXPublishStep1VC.createVC(type: .detail,
                                               activityId: self.viewModel.activityId,
                                               infoData: self.viewModel.infoData,
                                               picData: self.viewModel.picData)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func showAlertManagerActivity() {
        let action1 = GXAlertAction()
        action1.title = "编辑"
        action1.titleColor = .gx_black
        action1.titleFont = .gx_font(size: 17)
        action1.action = { alertView in
            alertView.hide(animated: true)
            self.gotoEditActivity()
        }
        let action2 = GXAlertAction()
        action2.title = "上架"
        action2.titleColor = .gx_drakGreen
        action2.titleFont = .gx_font(size: 17)
        action2.action = { alertView in
            alertView.hide(animated: true)
            self.requestSetShelfStatus()
        }
        let action3 = GXAlertAction()
        action3.title = "删除"
        action3.titleColor = .gx_red
        action3.titleFont = .gx_boldFont(size: 17)
        action3.action = { alertView in
            alertView.hide(animated: true)
            GXUtil.showAlert(title: "确认删除活动？", actionTitle: "确定") { alert, index in
                guard index == 1 else { return }
                self.requestActivityDelete()
            }
        }
        var otherActions: [GXAlertAction] = []
        let activityStatus = self.viewModel.infoData?.activityStatus ?? 0
        if activityStatus > 1 && activityStatus < 5 {
            otherActions = [action1, action2, action3]
        } else{
            otherActions = [action1, action3]
        }
        GXUtil.showSheet(otherActions: otherActions)
    }

    func showAlertRightItem() {
        let action1 = GXAlertAction()
        action1.title = "扫一扫"
        action1.titleColor = .gx_black
        action1.titleFont = .gx_boldFont(size: 17)
        let action2 = GXAlertAction()
        action2.title = "分享"
        action2.titleColor = .gx_black
        action2.titleFont = .gx_boldFont(size: 17)
        let action3 = GXAlertAction()
        action3.title = "活动二维码"
        action3.titleColor = .gx_black
        action3.titleFont = .gx_boldFont(size: 17)
        GXUtil.showSheet(otherActions: [action1, action2, action3]) { alert, index in
            guard index > 0 else { return }
            if index == 1 {
                self.showQRCodeReader()
            }
            else if index == 2 {
                self.showShareMenuView()
            }
            else if index == 3 {
                GXMinePtQrCodeView.showAlertView(type: .activity, text: String(self.viewModel.activityId))
            }
        }
    }

    func showQRCodeReader() {
        let vc = GXQRCodeReaderVC.xibViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.didFindCodeAction = {[weak self] (type, value, qrVC) in
            guard let `self` = self else { return }
            switch type {
            case .url:
                qrVC.dismiss(animated: true)
                let vc = GXWebViewController(urlString: value, title: "")
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case .user:
                qrVC.dismiss(animated: true)
                GXMinePtOtherVC.push(fromVC: self, userId: value)
            case .event:
                qrVC.dismiss(animated: true)
                GXToast.showError(text: "此为事件二维码，请切换至用户端参与！")
            case .ticket:
                GXApiUtil.requestActivityVerifyTicket(ticketCode: value, completion: {
                    qrVC.reader.startScanning()
                })
            case .activity:
                qrVC.dismiss(animated: true)
                GXToast.showError(text: "此为活动二维码，请切换至用户端参与！")
            default:
                qrVC.dismiss(animated: true)
                GXToast.showError(text: "未能识别\n" + value)
            }
        }
        self.present(vc, animated: true)
    }

    func showShareMenuView() {
        let height = 120 + self.view.safeAreaInsets.bottom + 10.0
        let shareView = GXSharePickerView.xibView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: self.view.width, height: height))
            $0.completion = {[weak self] index in
                self?.showShareMenuSelect(index: index)
            }
        }
        shareView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }

    func showShareMenuSelect(index: Int) {
        let scene: WXScene = (index == 1) ? WXSceneTimeline : WXSceneSession
        guard let listPics = self.viewModel.infoData?.listPics, let url = URL(string: listPics) else {
            GXWechatManager.shared.sharedWeb(activityId: self.viewModel.infoData?.id,
                                             activityName: self.viewModel.infoData?.activityName,
                                             activityTypeName: self.viewModel.infoData?.activityTypeName,
                                             image: nil,
                                             scene: scene, completion: { error in
                if let error = error {
                    let errText = error.errorInfo.count > 0 ? error.errorInfo : "分享失败"
                    GXToast.showError(text: errText)
                } else {
                    GXToast.showSuccess(text: "分享成功")
                }
            })
            return
        }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let image):
                GXWechatManager.shared.sharedWeb(activityId: self.viewModel.infoData?.id,
                                                 activityName: self.viewModel.infoData?.activityName,
                                                 activityTypeName: self.viewModel.infoData?.activityTypeName,
                                                 image: image.image,
                                                 scene: scene, completion: { error in
                    if let error = error {
                        let errText = error.errorInfo.count > 0 ? error.errorInfo : "分享失败"
                        GXToast.showError(text: errText)
                    } else {
                        GXToast.showSuccess(text: "分享成功")
                    }
                })
            case .failure(_):
                GXWechatManager.shared.sharedWeb(activityId: self.viewModel.infoData?.id,
                                                 activityName: self.viewModel.infoData?.activityName,
                                                 activityTypeName: self.viewModel.infoData?.activityTypeName,
                                                 image: nil,
                                                 scene: scene, completion: { error in
                    if let error = error {
                        let errText = error.errorInfo.count > 0 ? error.errorInfo : "分享失败"
                        GXToast.showError(text: errText)
                    } else {
                        GXToast.showSuccess(text: "分享成功")
                    }
                })
            }
        }
    }

}


