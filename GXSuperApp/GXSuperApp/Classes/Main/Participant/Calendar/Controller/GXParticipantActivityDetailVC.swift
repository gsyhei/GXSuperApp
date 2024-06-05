//
//  GXParticipantActivityDetailVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/11.
//

import UIKit
import MBProgressHUD
import GXSegmentPageView
import HXPhotoPicker
import XCGLogger
import Kingfisher

class GXParticipantActivityDetailVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var optionBarView: UIView!
    @IBOutlet weak var signUpGroupButton: UIButton!
    @IBOutlet weak var consultButton: UIButton!
    @IBOutlet weak var collectButton: UIButton!
    @IBOutlet weak var edidButton: UIButton!
    /// 我同意《产品服务协议》
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkTextView: GXLinkTextView!
    @IBOutlet weak var bottomBarHLC: NSLayoutConstraint!

    weak var segmentTitleView: GXSegmentTitleView?
    var beginDragging: Bool = false

    private lazy var viewModel: GXParticipantActivityDetailViewModel = {
        return GXParticipantActivityDetailViewModel()
    }()

    class func createVC(activityId: Int) -> GXParticipantActivityDetailVC {
        return GXParticipantActivityDetailVC.xibViewController().then {
            $0.viewModel.activityId = activityId
            $0.hidesBottomBarWhenPushed = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.signUpGroupButton.imageLocationAdjust(model: .top, spacing: 2)
        self.consultButton.imageLocationAdjust(model: .top, spacing: 2)
        self.collectButton.imageLocationAdjust(model: .top, spacing: 2)
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
        GXApiUtil.requestCreateEvent(targetType: 9)
    }

    override func setupViewController() {
        self.gx_addBackBarButtonItem()

        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ax_share"), style: .plain, target: self, action: #selector(self.rightButtonItemTapped))
        }
        self.edidButton.setBackgroundColor(.gx_black, for: .normal)
        self.optionBarView.isHidden = true

        self.checkButton.isSelected = true
        self.checkTextView.gx_setMarginZero()
        self.checkTextView.text = "我已阅读并同意"
        self.checkTextView.gx_appendLink(string: "《HEI VIBE产品服务协议》", color: UIColor.gx_drakGreen, urlString: "cpfwxy")
        self.checkTextView.delegate = self

        self.tableView.setTableFooterView(height: 8.0)
        self.tableView.register(cellType: GXPublishActivityDetailCell.self)
        self.tableView.register(cellType: GXPublishActivityDetailPicCell.self)
        self.tableView.register(cellType: GXPublishActivityDetailUserCell.self)
        self.tableView.register(cellType: GXPublishActivityDetailSecCell.self)
        self.tableView.register(cellType: GXActivityDetailTextCell.self)
        self.tableView.register(cellType: GXPtEventListCell.self)
        self.tableView.register(cellType: GXPtQuestionnaireListCell.self)
        self.tableView.register(cellType: GXPtReviewListCell.self)
        self.tableView.register(headerFooterViewType: GXPtActivityDetailTabHeader.self)
    }

    func updateTopView() {
        guard let info =  self.viewModel.infoData else { return }
        self.optionBarView.isHidden = false

        // 是否已搜藏 1-是 0-否
        if info.favoriteFlag == 1 {
            self.collectButton.isSelected = true
            self.collectButton.setTitle("已收藏", for: .normal)
        }
        else {
            self.collectButton.isSelected = false
            self.collectButton.setTitle("收藏", for: .normal)
        }

        self.bottomBarHLC.constant = 60.0
        self.checkButton.isHidden = true
        self.checkTextView.isHidden = true
        // 是否已报名 1-是 0-否
        if info.signFlag == 1 {
            self.signUpGroupButton.isHidden = false
            self.consultButton.isHidden = false
            // 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过
            self.edidButton.setTitle("发布回顾", for: .normal)
            self.edidButton.gx_setBlackButton()
        }
        else {
            self.signUpGroupButton.isHidden = true
            self.consultButton.isHidden = false
            // 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过
            if info.activityStatus == 4 {
                self.edidButton.gx_setDisabledButton()
                self.edidButton.setTitle("活动已结束", for: .normal)
            } else {
                let signModel = info.getSignUpModel()
                if signModel.canDateSignUp {
                    // 仅vip报名 1-是 0-否
                    if info.limitVip == 1 && !(GXUserManager.shared.user?.vipFlag ?? false) {
                        self.edidButton.gx_setDisabledButton()
                        self.edidButton.setTitle("仅VIP可报名", for: .normal)
                    }
                    else {
                        self.edidButton.gx_setBlackButton()
                        if let ticket = signModel.ticket {
                            self.setPriceLabel(ticket: ticket, activityMode: info.activityMode)
                        } else {
                            self.edidButton.setTitle("我要报名", for: .normal)
                        }
                        self.bottomBarHLC.constant = 90.0
                        self.checkButton.isHidden = false
                        self.checkTextView.isHidden = false
                    }
                }
                else {
                    if signModel.canDateSignType == 0 {
                        self.edidButton.gx_setDisabledButton()
                        self.edidButton.setTitle("报名时间未到", for: .normal)
                    }
                    else {
                        self.edidButton.gx_setDisabledButton()
                        self.edidButton.setTitle("报名时间已过", for: .normal)
                    }
                }
            }
        }
    }

    func setPriceLabel(ticket: GXActivityticketlistItem?, activityMode: Int) {
        guard let ticketItem = ticket, activityMode == 2 else {
            self.edidButton.setTitle("我要报名", for: .normal)
            return
        }
        let isVip: Bool = (GXUserManager.shared.user?.vipFlag ?? false)
        if ticketItem.ticketType == 2 {
            if ticketItem.vipPrice.count > 0 && isVip {
                self.edidButton.setTitle("我要报名 ￥\(ticketItem.vipPrice)", for: .normal)
            }
            else {
                self.edidButton.setTitle("我要报名 ￥\(ticketItem.normalPrice)", for: .normal)
            }
        }
        else {
            let vipPrice: Float = Float(ticketItem.vipPrice) ?? 0
            let normalPrice: Float = Float(ticketItem.normalPrice) ?? 0
            if (vipPrice == 0 && normalPrice == 0) || (!isVip && normalPrice == 0) {
                self.edidButton.setTitle("我要报名", for: .normal)
                return
            }
            if ticketItem.vipPrice.count > 0 && isVip {
                self.edidButton.setTitle("我要报名 ￥\(ticketItem.vipPrice)", for: .normal)
            }
            else {
                self.edidButton.setTitle("我要报名 ￥\(ticketItem.normalPrice)", for: .normal)
            }
        }
    }
}

extension GXParticipantActivityDetailVC {
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
    
    func requestGetActivityBaseInfo() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetActivityBaseInfo(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateTopView()
            self?.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestSignActivity() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSignActivity(success: {[weak self] data in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.updateTopView()
            if let letData = data {
                if letData.orderSn.count > 0 {
                    let vc = GXPtActivitySelectPayVC.createVC(infoData: self.viewModel.infoData, signData: letData)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let vc = GXPtActivityPaySuccVC.createVC(infoData: self.viewModel.infoData, signData: letData)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                let vc = GXPtActivityPaySuccVC.createVC(infoData: self.viewModel.infoData, signData: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestAddFavorite() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAddFavorite(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateTopView()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func showReportSheet(chatId: Int) {
        let view = GXReportPickerView.xibView().then {
            $0.backgroundColor = .white
            $0.frame = CGRect(origin: .zero, size: CGSize(width: self.view.width, height: 320))
            $0.completion = { list in
                let listStr = list.joined(separator: ",")
                GXApiUtil.requestCreateReportViolation(chatId: chatId, chatType: 1, reportingReason: listStr)
            }
        }
        view.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
}

extension GXParticipantActivityDetailVC: UITableViewDataSource, UITableViewDelegate {

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
            // ["问卷", "事件", "回顾"]
            let title = self.viewModel.bottomTitles[section - 2]
            if title == "问卷" {
                return self.viewModel.questionaireList.count + 1
            }
            else if title == "事件" {
                return self.viewModel.eventsList.count + 1
            }
            else {
                return self.viewModel.reviewsList.count + 1
            }
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
        else {
            if indexPath.row == 0 {
                return 56.0
            }
            else {
                // ["问卷", "事件", "回顾"]
                let title = self.viewModel.bottomTitles[indexPath.section - 2]
                if title == "问卷" {
                    let model = self.viewModel.questionaireList[indexPath.row - 1]
                    return GXPtQuestionnaireListCell.heightCell(model: model)
                }
                else if title == "事件" {
                    let model = self.viewModel.eventsList[indexPath.row - 1]
                    return GXPtEventListCell.heightCell(model: model)
                }
                else {
                    let model = self.viewModel.reviewsList[indexPath.row - 1]
                    return GXPtReviewListCell.heightCell(model: model)
                }
            }
        }
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
            cell.cdmapAction = {[weak self] in
                guard let `self` = self else { return }
                let vc = GXPtActivityMapsVC(activityId: self.viewModel.activityId)
                self.navigationController?.pushViewController(vc, animated: true)
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
                guard let `self` = self else { return }
                self.tableView.reloadData()
            }
            return cell
        }
        else {
            // ["问卷", "事件", "回顾"]
            let title = self.viewModel.bottomTitles[indexPath.section - 2]
            if indexPath.row == 0 {
                let cell: GXPublishActivityDetailSecCell = tableView.dequeueReusableCell(for: indexPath)
                cell.titleLabel.text = title
                return cell
            }
            else {
                if title == "问卷" {
                    let cell: GXPtQuestionnaireListCell = tableView.dequeueReusableCell(for: indexPath)
                    let model = self.viewModel.questionaireList[indexPath.row - 1]
                    cell.bindCell(model: model)
                    cell.attendAction = {[weak self] curCell in
                        guard let `self` = self else { return }
                        guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
                        let curModel = self.viewModel.questionaireList[curIndexPath.row - 1]
                        let vc = GXPtQuestionnaireSubmitVC.createVC(questionaireData: curModel)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    return cell
                }
                else if title == "事件" {
                    let cell: GXPtEventListCell = tableView.dequeueReusableCell(for: indexPath)
                    let model = self.viewModel.eventsList[indexPath.row - 1]
                    cell.bindCell(model: model)
                    cell.attendAction = {[weak self] curCell in
                        guard let `self` = self else { return }
                        guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
                        let curModel = self.viewModel.eventsList[curIndexPath.row - 1]
                        let vc = GXPtEventDetailVC.createVC(eventData: curModel)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    return cell
                }
                else {
                    let cell: GXPtReviewListCell = tableView.dequeueReusableCell(for: indexPath)
                    let model = self.viewModel.reviewsList[indexPath.row - 1]
                    cell.bindCell(model: model)
                    cell.avatarAction = {[weak self] curCell in
                        guard let `self` = self else { return }
                        guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
                        guard let userId = self.viewModel.reviewsList[curIndexPath.row - 1].userId else { return }
                        GXMinePtOtherVC.push(fromVC: self, userId: String(userId))
                    }
                    cell.moreAction = {[weak self] curCell in
                        guard let `self` = self else { return }
                        guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
                        guard let chatId = self.viewModel.reviewsList[curIndexPath.row - 1].id else { return }
                        self.showReportSheet(chatId: chatId)
                    }
                    return cell
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = tableView.dequeueReusableHeaderFooterView(GXPtActivityDetailTabHeader.self)
            header?.bindView(titles: self.viewModel.headerTitles)
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
        else if indexPath.section > 1 && indexPath.row == 0 {
            // ["问卷", "事件", "回顾"]
            let title = self.viewModel.bottomTitles[indexPath.section - 2]
            if title == "问卷" {
                let vc = GXPtQuestionnaireListVC(activityId: self.viewModel.activityId)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if title == "事件" {
                let vc = GXPtEventListVC(activityId: self.viewModel.activityId)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = GXPtReviewListVC(activityId: self.viewModel.activityId)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}

extension GXParticipantActivityDetailVC: GXSegmentTitleViewDelegate {
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

extension GXParticipantActivityDetailVC {
    @objc func rightButtonItemTapped() {
        GXApiUtil.requestCreateEvent(targetType: 8)
        let height = 120 + self.view.safeAreaInsets.bottom + 10.0
        let shareView = GXSharePickerView.xibView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: self.view.width, height: height))
            $0.completion = {[weak self] index in
                self?.showShareMenuSelect(index: index)
            }
        }
        shareView.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
    @IBAction func checkedButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func signUpGroupButtonClicked(_ sender: UIButton) {
        // 报名群
        let vc = GXChatViewController(messageType: 3,
                                      activityId: self.viewModel.activityId,
                                      title: self.viewModel.infoData?.activityName)
        let nav = GXBaseNavigationController(rootViewController: vc)
        self.gx_present(nav, style: .push)
    }
    @IBAction func consultButtonClicked(_ sender: UIButton) {
        // 活动咨询
        let vc = GXChatViewController(messageType: 1,
                                      activityId: self.viewModel.activityId,
                                      title: self.viewModel.infoData?.activityName)
        let nav = GXBaseNavigationController(rootViewController: vc)
        self.gx_present(nav, style: .push)
    }
    @IBAction func collectButtonClicked(_ sender: UIButton) {
        self.requestAddFavorite()
    }
    @IBAction func edidButtonClicked(_ sender: UIButton) {
        let title = sender.title(for: .normal) ?? ""
        if title.contains(find: "我要报名") {
            guard self.checkButton.isSelected else {
                GXToast.showError(text: "请先勾选同意以上协议", to: self.view)
                return
            }
            let navc = self.navigationController as? GXBaseNavigationController
            if GXUserManager.gotoSignUp(navc: navc) {
                self.requestSignActivity()
            }
        }
        else if title == "发布回顾" {
            GXApiUtil.requestCreateEvent(targetType: 14, activityId: self.viewModel.activityId)
            let vc = GXPublishReviewEidtVC.createVC(activityId: self.viewModel.activityId)
            self.navigationController?.pushViewController(vc, animated: true)
        }
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

extension GXParticipantActivityDetailVC: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.didLinkScheme(URL.absoluteString)
        return false
    }
    func didLinkScheme(_ scheme: String) {
        switch scheme {
        case "cpfwxy":
            let urlString = Api_WebBaseUrl + "/h5/#/agreement/4"
            let vc = GXWebViewController(urlString: urlString, title: "HEI VIBE产品服务协议")
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}


