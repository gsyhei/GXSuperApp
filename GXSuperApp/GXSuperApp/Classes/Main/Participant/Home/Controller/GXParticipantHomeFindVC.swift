//
//  GXParticipantHomeFindVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/5.
//

import UIKit
import XCGLogger
import MBProgressHUD
import CoreLocation
import GXRefresh
import QRCodeReader

class GXParticipantHomeFindVC: GXBaseViewController {
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: GXBaseTableView!
    private var isLoadActivityPage: Bool = false

    lazy var viewModel: GXParticipantHomeFindViewModel = {
        return GXParticipantHomeFindViewModel()
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.locationButton.imageLocationAdjust(model: .right, spacing: 2.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.requestGetAllData()
        NotificationCenter.default.rx
            .notification(GX_NotifName_ChangeCity)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.showLocationChange()
            }).disposed(by: disposeBag)
    }
    
    override func setupViewController() {
        self.view.backgroundColor = .clear

        let city = GXUserManager.shared.city
        let maxLenCity = (city.count > 4) ? city[0..<4] : city
        self.locationButton.setTitle(maxLenCity, for: .normal)

        self.tableView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(cellType: GXParticipantHomeDtCell.self)
        self.tableView.register(cellType: GXParticipantHomeDtBannerCell.self)
        self.tableView.register(cellType: GXParticipantHomeDtButtonCell.self)
        self.tableView.register(cellType: GXPrHomeActivityPageCell.self)
        self.tableView.register(headerFooterViewType: GXPrHomeActivityPageHeader.self)
        self.tableView.register(headerFooterViewType: GXPrHomeActivitySignHeader.self)

        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requestGetAllData(completion: {
                self?.tableView.gx_header?.endRefreshing(isNoMore: true, isSucceed: true)
            })
        }).then({ header in
            header.updateRefreshTitles()
        })
    }

    func showLocationChange() {
        let city = GXUserManager.shared.city
        let maxLenCity = (city.count > 4) ? city[0..<4] : city
        self.locationButton.setTitle(maxLenCity, for: .normal)
        self.requestCityActivityPage()
    }
}

extension GXParticipantHomeFindVC {

    func requestGetAllData(completion: GXActionBlock? = nil) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetAllData {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
            completion?()
        } stepSuccess: {[weak self] in
            self?.tableView.gx_reloadData()
        } failure: { error in }
    }

    func requestCityActivityPage() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestCityActivityPage(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
        }, stepSuccess: {[weak self] in
            self?.tableView.gx_reloadData()
        }, failure: {error in })
    }

    func requestActivityPage() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetActivityPage {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.reloadSection(2, with: .automatic)
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }

    func requestGetActivityBaseInfo(activityId: Int) {
        MBProgressHUD.showLoading(text: "扫码识别中", style: .circle, to: self.view)
        self.viewModel.requestGetActivityBaseInfo(activityId: activityId, success: {[weak self] data in
            MBProgressHUD.dismiss(for: self?.view)
            self?.pushQRCodeActivity(info: data)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(text: "此活动暂不开放", to: self?.view)
        })
    }

    func pushQRCodeActivity(info: GXActivityBaseInfoData?) {
        guard let info = info else {
            GXToast.showError(text: "此活动暂不开放", to: self.view)
            return
        }
        // 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过
        if info.activityStatus == 3 || info.activityStatus == 4 {
            let vc = GXParticipantActivityDetailVC.createVC(activityId: info.id)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            GXToast.showError(text: "此活动暂不开放", to: self.view)
        }
    }

}

extension GXParticipantHomeFindVC {
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        let vc = GXParticipantHomeCityVC(style: .plain).then {
            $0.selectedCity = GXUserManager.shared.city
        }
        vc.hidesBottomBarWhenPushed = true
        vc.selectedAction = {[weak self] city in
            GXUserManager.updateCity(city)
            NotificationCenter.default.post(name: GX_NotifName_ChangeCity, object: nil)
            let maxLenCity = (city.count > 4) ? city[0..<4] : city
            self?.locationButton.setTitle(maxLenCity, for: .normal)
            self?.requestCityActivityPage()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func qrCodeButtonClicked(_ sender: UIButton) {
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
                if let eventId = Int(value) {
                    let vc = GXPtEventDetailVC.createVC(eventId: eventId)
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .ticket:
                qrVC.dismiss(animated: true)
                GXToast.showError(text: "此为门票二维码，请切换至发布者端核销！")
            case .activity:
                qrVC.dismiss(animated: true)
                if let activityId = Int(value) {
                    self.requestGetActivityBaseInfo(activityId: activityId)
                }
            default:
                qrVC.dismiss(animated: true)
                GXToast.showError(text: "未能识别\n" + value)
            }
        }
        self.present(vc, animated: true)
    }

    @IBAction func searchButtonClicked(_ sender: UIButton) {
        self.searchBarView.hero.id = GXParticipantHomeSearchVCHeroId
        let vc = GXParticipantHomeSearchVC.xibViewController()
        let navc = GXBaseNavigationController(rootViewController: vc)
        navc.hero.isEnabled = true
        navc.modalPresentationStyle = .fullScreen
        self.present(navc, animated: true)
    }
}

extension GXParticipantHomeFindVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.viewModel.dtSectionList.count
        }
        else if section == 1 {
            if self.viewModel.mySignTabNumber > 0 {
                return self.viewModel.mySignActivityData?.selectedCount(index: self.viewModel.mySignIndex) ?? 0
            } else {
                return 0
            }
        }
        else {
            return self.viewModel.activityPageList.count
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        else if section == 1 {
            if self.viewModel.mySignTabNumber == 0 {
                return nil
            }
            let header = tableView.dequeueReusableHeaderFooterView(GXPrHomeActivitySignHeader.self)
            header?.bindView(mySignIndex: self.viewModel.mySignIndex, isShowAll: self.viewModel.mySignTabNumber == 2)
            header?.mySignAction = {[weak self] signIndex in
                guard let `self` = self else { return }
                self.viewModel.mySignIndex = signIndex
                self.tableView.reloadSection(1, with: .automatic)
            }
            header?.reloadMoreAction = {[weak self] in
                guard let `self` = self else { return }
                guard let data = self.viewModel.mySignActivityData else { return }
                let vc = GXParticipantHomeMysignVC.createVC(data: data, index: self.viewModel.mySignIndex)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return header
        }
        else {
            let header = tableView.dequeueReusableHeaderFooterView(GXPrHomeActivityPageHeader.self)
            header?.bindView(viewModel: self.viewModel)
            header?.reloadPageAction = {[weak self] in
                guard let `self` = self else { return }
                self.requestActivityPage()
            }
            header?.reloadFilterAction = {[weak self] in
                guard let `self` = self else { return }
                self.showAllFilterButtonClicked()
            }
            header?.reloadMoreAction = {[weak self] in
                guard let `self` = self else { return }
                let vc = GXParticipantCalendarVC.xibViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return header
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let model = self.viewModel.dtSectionList[indexPath.row]
            if let list = model as? [GXPtHomeGetMusicStationsItem] {
                let cell: GXParticipantHomeDtCell = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell(list: list)

                return cell
            }
            else if let list = model as? [GXPtHomeListBannerItem] {
                let cell: GXParticipantHomeDtBannerCell = tableView.dequeueReusableCell(for: indexPath)
                cell.bindCell(list: list)
                cell.bannerAction = {[weak self] model in
                    self?.bannerAction(item: model)
                }
                return cell
            }
            else {
                let cell: GXParticipantHomeDtButtonCell = tableView.dequeueReusableCell(for: indexPath)
                let aqtModel = model as? GXPtHomeActQueTicketData
                cell.bindCell(model: aqtModel)
                cell.buttonAction = {[weak self] (index, model) in
                    self?.actQueTicketDataAction(model, index: index)
                }
                return cell
            }
        }
        else if indexPath.section == 1 {
            let cell: GXPrHomeActivityPageCell = tableView.dequeueReusableCell(for: indexPath)
            if self.viewModel.mySignIndex == 0 {
                let model = self.viewModel.mySignActivityData?.goingActivityList[indexPath.row]
                cell.bindCell(model: model)
            }
            else {
                let model = self.viewModel.mySignActivityData?.notStartActivityList[indexPath.row]
                cell.bindCell(model: model)
            }
            return cell
        }
        else {
            let cell: GXPrHomeActivityPageCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.activityPageList[indexPath.row])

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let model = self.viewModel.dtSectionList[indexPath.row]
            if model is [GXPtHomeGetMusicStationsItem] {
                return 166.0
            }
            else if model is [GXPtHomeListBannerItem] {
                return 112.0
            }
            else {
                return 62.0
            }
        }
        else if indexPath.section == 1 {
            return 136.0
        }
        else {
            return 170.0
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return .zero
        }
        else if section == 1 {
            if self.viewModel.mySignTabNumber == 0 {
                return .zero
            }
            return 42.0
        }
        else {
            return 82.0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        guard let pageCell = cell as? GXPrHomeActivityPageCell else { return }
        GXBaseTableView.setTableView(tableView, roundView: pageCell.containerView, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if self.viewModel.mySignIndex == 0 {
                guard let model = self.viewModel.mySignActivityData?.goingActivityList[indexPath.row] else { return }
                GXApiUtil.requestCreateEvent(targetType: 4, targetId: model.id)
                let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                guard let model = self.viewModel.mySignActivityData?.notStartActivityList[indexPath.row] else { return }
                let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.section == 2 {
            let model = self.viewModel.activityPageList[indexPath.row]
            GXApiUtil.requestCreateEvent(targetType: 5, targetId: model.id)
            let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension GXParticipantHomeFindVC {
    func bannerAction(item: GXPtHomeListBannerItem?) {
        guard let item = item else { return }
        GXApiUtil.requestClickBanner(bannerId: item.id)
        if item.linkType == 1 { // 活动
            let vc = GXParticipantActivityDetailVC.createVC(activityId: item.activityId)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if item.linkType == 2 { // 其他
            let vc = GXWebViewController(urlString: item.otherPage, title: item.bannerTitle)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func actQueTicketDataAction(_ data: GXPtHomeActQueTicketData?, index: Int) {
        guard let data = data else { return }
        switch index {
        case 0:
            GXApiUtil.requestCreateEvent(targetType: 3)
            let vc = GXParticipantCalendarVC.xibViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            GXApiUtil.requestCreateEvent(targetType: 6)
            if data.activityQuestionaireId.count > 0 {
                let vc = GXPtQuestionnaireSubmitVC.createVC(questionaireId: Int(data.activityQuestionaireId))
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            guard data.ticketBroadcastId.count > 0 else { return }
            GXApiUtil.requestClickBroadcast(broadcastId: data.ticketBroadcastId)
            GXApiUtil.requestCreateEvent(targetType: 2)

            let vc = GXParticipantActivityDetailVC.createVC(activityId: data.broadCastActivityId)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }

    func showAllFilterButtonClicked() {
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.height-250)
        let menu = GXActivityTypePickerView(frame: rect,
                                            activityTypeIds: self.viewModel.activityTypeIds,
                                            priceType: self.viewModel.priceType)
        menu.show(to: self.contentView, style: .sheetTop)
        menu.selectedAction = {[weak self] (activityTypeIds, priceType) in
            self?.viewModel.activityTypeIds = activityTypeIds
            self?.viewModel.priceType = priceType
            self?.requestActivityPage()
        }
    }
}
