//
//  GXParticipantCalendarVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import CoreLocation
import XCGLogger
import GXRefresh
import MBProgressHUD

class GXParticipantCalendarVC: GXBaseViewController {
    @IBOutlet weak var calendarDayView: GXHorizontalCalendarDayView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cityButton: GXArrowButton!
    @IBOutlet weak var filterButton: GXArrowButton!
    @IBOutlet weak var sortButton: GXArrowButton!
    @IBOutlet weak var tableView: GXBaseTableView!

    private weak var calendarMenu: GXVerticalCalendarMenu?
    private weak var sortMenu: GXSelectItemsMenu?
    private weak var cityMenu: GXCityPickerView?
    private weak var filterMenu: GXActivityTypePickerView?

    private lazy var viewModel: GXParticipantCalendarViewModel = {
        return GXParticipantCalendarViewModel()
    }()

    override func viewWillAppear(_ animated: Bool) {          
        super.viewWillAppear(animated)
        if !self.hidesBottomBarWhenPushed {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !self.hidesBottomBarWhenPushed {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.cityButton.imageLocationAdjust(model: .right, spacing: 0)
        self.filterButton.imageLocationAdjust(model: .right, spacing: 0)
        self.sortButton.imageLocationAdjust(model: .right, spacing: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestRefreshData()
        self.requestGetCalendarDot()
        NotificationCenter.default.rx
            .notification(GX_NotifName_ChangeCity)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.cityButton.setTitle(GXUserManager.shared.city, for: .normal)
                self?.requestRefreshData()
                self?.requestGetCalendarDot()
            }).disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(GX_NotifName_HCalendarSelected)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.requestRefreshData()
            }).disposed(by: disposeBag)
    }

    override func setupViewController() {
        if self.hidesBottomBarWhenPushed {
            self.gx_addBackBarButtonItem()
        }
        self.calendarDayView.bindViewModel(viewModel: self.viewModel.calendar)

        self.cityButton.setTitle(GXUserManager.shared.city, for: .normal)
//        if let item = GXActivityManager.shared.sortItems.first(where: { $0.status == self.viewModel.sortBy }) {
//            self.sortButton.setTitle(item.title, for: .normal)
//        }

        self.tableView.rowHeight = 170.0
        self.tableView.separatorColor = .gx_lightGray
        self.tableView.placeholder = "暂⽆活动"
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

extension GXParticipantCalendarVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestCalendarActivity(refresh: isRefresh, success: {[weak self] isLastPage in
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

    func requestGetCalendarDot() {
        self.viewModel.requestGetCalendarDot {[weak self] in
            self?.calendarDayView.reloadData()
        } failure: { error in }
    }
    
}

extension GXParticipantCalendarVC {
    @IBAction func calendarButtonClicked(_ sender: UIButton) {
        if let letMenu = self.calendarMenu {
            letMenu.hide(animated: true)
            return
        }
        if self.cityButton.isSelected {
            self.cityButtonClicked(self.cityButton)
        }
        if self.filterButton.isSelected {
            self.filterButtonClicked(self.filterButton)
        }
        if self.sortButton.isSelected {
            self.sortButtonClicked(self.sortButton)
        }
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.height-400)
        let menu = GXVerticalCalendarMenu(frame: rect)
        menu.calendarDayView.bindViewModel(viewModel: self.viewModel.calendar)
        menu.show(to: self.containerView, style: .sheetTop)
        self.calendarMenu = menu
    }

    @IBAction func cityButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.cityMenu?.hide(animated: true)
            return
        }
        if self.filterButton.isSelected {
            self.filterButtonClicked(self.filterButton)
        }
        if self.sortButton.isSelected {
            self.sortButtonClicked(self.sortButton)
        }
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.height-450)
        let menu = GXCityPickerView(frame: rect, selectedCity: GXUserManager.shared.city)
        menu.show(to: self.contentView, style: .sheetTop, dismissBlock: {[weak self] in
            self?.cityButton.isSelected = false
        })
        menu.selectedAction = {[weak self] city in
            GXUserManager.updateCity(city)
            self?.cityButton.setTitle(city, for: .normal)
            NotificationCenter.default.post(name: GX_NotifName_ChangeCity, object: nil)
        }
        self.cityMenu = menu
    }

    @IBAction func filterButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.filterMenu?.hide(animated: true)
            return
        }
        if self.sortButton.isSelected {
            self.sortButtonClicked(self.sortButton)
        }
        if self.cityButton.isSelected {
            self.cityButtonClicked(self.cityButton)
        }
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.height-450)
        let menu = GXActivityTypePickerView(frame: rect,
                                            activityTypeIds: self.viewModel.activityTypeIds,
                                            priceType: self.viewModel.priceType)
        menu.show(to: self.contentView, style: .sheetTop, dismissBlock: {[weak self] in
            self?.filterButton.isSelected = false
        })
        menu.selectedAction = {[weak self] (activityTypeIds, priceType) in
            self?.viewModel.activityTypeIds = activityTypeIds
            self?.viewModel.priceType = priceType
            self?.requestRefreshData()
        }
        self.filterMenu = menu
    }

    @IBAction func sortButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.sortMenu?.hide(animated: true)
            return
        }
        if self.filterButton.isSelected {
            self.filterButtonClicked(self.filterButton)
        }
        if self.cityButton.isSelected {
            self.cityButtonClicked(self.cityButton)
        }
        let menu = GXSelectItemsMenu(items: GXActivityManager.shared.sortItems, multipleSelection: false)
        menu.show(to: self.contentView, style: .sheetTop, dismissBlock: {[weak self] in
            self?.sortButton.isSelected = false
        })
        menu.selected(status: self.viewModel.sortBy)
        menu.selectedAction = {[weak self] selectedItems in
            guard let item = selectedItems.first else { return }
//            self?.sortButton.setTitle(item.title, for: .normal)
            self?.viewModel.sortBy = item.status
            self?.requestRefreshData()
        }
        self.sortMenu = menu
    }
}

extension GXParticipantCalendarVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPrCalendarActivityPageCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindCell(model: model)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
