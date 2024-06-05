//
//  GXPtEventDetailVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/31.
//

import UIKit
import MBProgressHUD
import HXPhotoPicker

class GXPtEventDetailVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var submitButton: UIButton!
    
    private var eventMapsAssets: [PhotoAsset] = []
    private var eventPicsAssets: [PhotoAsset] = []
    private var eventId: Int?
    private var eventData: GXPublishEventStepData? {
        didSet {
            guard let letEventData = eventData else { return }
            self.eventId = letEventData.id
            self.eventMapsAssets = PhotoAsset.gx_photoAssets(pics: letEventData.eventMaps)
            self.eventPicsAssets = PhotoAsset.gx_photoAssets(pics: letEventData.eventPics)
        }
    }

    class func createVC(eventData: GXPublishEventStepData? = nil, eventId: Int? = nil) -> GXPtEventDetailVC {
        return GXPtEventDetailVC.xibViewController().then {
            $0.eventId = eventId
            $0.eventData = eventData
            $0.hidesBottomBarWhenPushed = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetEventDetail()
        GXApiUtil.requestCreateEvent(targetType: 10, targetId: self.eventId)
    }

    override func setupViewController() {
        self.title = self.eventData?.eventTitle
        self.gx_addBackBarButtonItem()
        
        self.submitButton.setBackgroundColor(.green, for: .normal)
        self.tableView.register(headerFooterViewType: GXPtEventDetailMapsHeader.self)
        self.tableView.register(headerFooterViewType: GXPtEventDetailPicsHeader.self)
        self.tableView.register(headerFooterViewType: GXPtEventDetailUsersHeader.self)
        self.tableView.register(cellType: GXPublishActivityDetailPicCell.self)
        self.tableView.register(cellType: GXPtEventDetailUsersCell.self)

        self.updateEventDetail()
    }

    func updateEventDetail() {
        guard let eventData = self.eventData else { return }

        // 获奖排序
        if let eventSigns = eventData.eventSigns {
            var pushSigns: [GXPublishEventsignsData] = []
            var noSigns: [GXPublishEventsignsData] = []
            for sign in eventSigns {
                if (sign.pushMessageFlag ?? false) || !(sign.eventReward?.isEmpty ?? true) {
                    if sign.userId == GXUserManager.shared.user?.id {
                        pushSigns.insert(sign, at: 0)
                    } else {
                        pushSigns.append(sign)
                    }
                } else {
                    noSigns.append(sign)
                }
            }
            eventData.eventSigns = pushSigns + noSigns
        }

        self.title = eventData.eventTitle
        // 事件是否已报名 1-是 0-否
        if eventData.signEventFlag == 1 {
            self.submitButton.setTitle("已参加", for: .normal)
            self.submitButton.gx_setDisabledButton()
        }
        else {
            // 拼接报名开始时间
            let signUpBeginStr = (eventData.signBeginDate ?? "") + "-" + (eventData.signBeginTime ?? "")
            let signUpBeginDate = Date.date(dateString: signUpBeginStr, format: "yyyyMMdd-HH:mm") ?? Date()
            // 拼接报名结束时间
            let signUpEndStr = (eventData.signEndDate ?? "") + "-" + (eventData.signEndTime ?? "")
            let signUpEndDate = Date.date(dateString: signUpEndStr, format: "yyyyMMdd-HH:mm") ?? Date()

            if signUpBeginDate > GXServiceManager.shared.systemDate {
                self.submitButton.setTitle("报名未开始", for: .normal)
                self.submitButton.gx_setDisabledButton()
            }
            if signUpEndDate < GXServiceManager.shared.systemDate {
                self.submitButton.setTitle("报名有效期已过", for: .normal)
                self.submitButton.gx_setDisabledButton()
            }
            else {
                self.submitButton.setTitle("立即参加", for: .normal)
                self.submitButton.gx_setGreenButton()
            }
        }
    }

    @IBAction func submitButtonClicked(_ sender: UIButton) {
        self.requestSignEvent()
    }
}

extension GXPtEventDetailVC {
    /// 获取事件详情
    func requestGetEventDetail() {
        guard let eventId = self.eventId else { return }
        MBProgressHUD.showLoading(to: self.view)
        var params: Dictionary<String, Any> = [:]
        params["eventId"] = eventId
        let api = GXApi.normalApi(Api_CEvent_GetEventDetail, params, .get)
        GXNWProvider.login_request(api, type: GXPublishGetEventDetailModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.eventData = model.data
            self.updateEventDetail()
            self.tableView.reloadData()
            MBProgressHUD.dismiss(for: self.view)
        }) {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }
    func requestSignEvent() {
        guard let eventId = self.eventId else { return }
        MBProgressHUD.showLoading(to: self.view)
        var params: Dictionary<String, Any> = [:]
        params["eventId"] = eventId
        let api = GXApi.normalApi(Api_CEvent_SignEvent, params, .post)
        GXNWProvider.login_request(api, type: GXPublishGetEventDetailModel.self, success: {[weak self] model in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showSuccess(text: "报名成功")
            self?.requestGetEventDetail()
        }) {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }
}

extension GXPtEventDetailVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.eventMapsAssets.count
        }
        else if section == 1 {
            return self.eventPicsAssets.count
        }
        else {
            return self.eventData?.eventSigns?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: GXPublishActivityDetailPicCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindModel(asset: self.eventMapsAssets[indexPath.row]) {[weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell: GXPublishActivityDetailPicCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindModel(asset: self.eventPicsAssets[indexPath.row]) {[weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return cell
        }
        else {
            let cell: GXPtEventDetailUsersCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.eventData?.eventSigns?[indexPath.row], index: indexPath.row)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(GXPtEventDetailMapsHeader.self)
            header?.bindView(model: self.eventData)

            return header
        }
        else if section == 1 {
            let header = tableView.dequeueReusableHeaderFooterView(GXPtEventDetailPicsHeader.self)
            header?.bindView(model: self.eventData)

            return header
        }
        else {
            let header = tableView.dequeueReusableHeaderFooterView(GXPtEventDetailUsersHeader.self)

            return header
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 100.0
        }
        else if section == 1 {
            return 50.0
        }
        else {
            return 50.0
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return GXPublishActivityDetailPicCell.height(asset: self.eventMapsAssets[indexPath.row])
        }
        else if indexPath.section == 1 {
            return GXPublishActivityDetailPicCell.height(asset: self.eventPicsAssets[indexPath.row])
        }
        else {
            return 60.0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            guard let cell = tableView.cellForRow(at: indexPath) as? GXPublishActivityDetailPicCell else { return }
            HXPhotoPicker.PhotoBrowser.show(pageIndex: indexPath.row, transitionalImage: cell.picImageView.image) {
                self.eventMapsAssets.count
            } assetForIndex: {
                self.eventMapsAssets[$0]
            } transitionAnimator: { index in
                let curIndexPath = IndexPath(row: index, section: indexPath.section)
                let cell = tableView.cellForRow(at: curIndexPath) as? GXPublishActivityDetailPicCell
                return cell?.picImageView
            }
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.cellForRow(at: indexPath) as? GXPublishActivityDetailPicCell else { return }
            HXPhotoPicker.PhotoBrowser.show(pageIndex: indexPath.row, transitionalImage: cell.picImageView.image) {
                self.eventPicsAssets.count
            } assetForIndex: {
                self.eventPicsAssets[$0]
            } transitionAnimator: { index in
                let curIndexPath = IndexPath(row: index, section: indexPath.section)
                let cell = tableView.cellForRow(at: curIndexPath) as? GXPublishActivityDetailPicCell
                return cell?.picImageView
            }
        }
        else {
            guard let userId = self.eventData?.eventSigns?[indexPath.row].userId else { return }
            GXMinePtOtherVC.push(fromVC: self, userId: String(userId))
        }
    }
}
