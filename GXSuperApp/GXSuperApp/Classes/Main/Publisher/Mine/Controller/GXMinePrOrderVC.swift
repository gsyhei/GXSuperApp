//
//  GXMinePrOrderVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import MBProgressHUD
import GXRefresh
import Hero

class GXMinePrOrderVC: GXBaseViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var activFilterButton: GXArrowButton!
    @IBOutlet weak var cycleFilterButton: GXArrowButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: GXBaseTableView!
    
    var cycleFilterMenu: GXSelectItemsMenu?
    var activFilterMenu: GXActivitySelectItemsMenu?

    private lazy var viewModel: GXMinePrOrderViewModel = {
        return GXMinePrOrderViewModel()
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.activFilterButton.imageLocationAdjust(model: .right, spacing: 0)
        self.cycleFilterButton.imageLocationAdjust(model: .right, spacing: 0)
        self.searchButton.imageLocationAdjust(model: .left, spacing: 2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
    }

    override func setupViewController() {
        self.title = "我的订单"
        self.view.backgroundColor = .gx_background
        self.gx_addBackBarButtonItem()

        self.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        self.tableView.rowHeight = 148.0
        self.tableView.placeholder = "暂无订单"
        self.tableView.register(cellType: GXMinePtOrderCell.self)
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

extension GXMinePrOrderVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetMyOrders(refresh: isRefresh, success: {[weak self] isLastPage in
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

extension GXMinePrOrderVC {
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        self.searchButton.hero.id = GXMinePrOrderSearchVCHeroId
        let vc = GXMinePrOrderSearchVC.xibViewController()
        let navc = GXBaseNavigationController(rootViewController: vc)
        navc.hero.isEnabled = true
        navc.modalPresentationStyle = .fullScreen
        self.present(navc, animated: true)
    }

    @IBAction func activFilterButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.activFilterMenu?.hide(animated: true)
            return
        }
        if self.cycleFilterButton.isSelected {
            self.cycleFilterButtonClicked(self.cycleFilterButton)
        }
        let menu = GXActivitySelectItemsMenu(height: SCREEN_HEIGHT-300, viewModel: self.viewModel)
        menu.show(to: self.contentView, style: .sheetTop, dismissBlock: {[weak self] in
            self?.activFilterButton.isSelected = false
        })
        menu.selected(data: self.viewModel.activityData)
        menu.selectedAction = {[weak self] selectedItems in
            guard let item = selectedItems.first else { return }
            self?.activFilterButton.setTitle(item.activityName, for: .normal)
            self?.viewModel.activityData = item
            self?.requestRefreshData()
        }
        self.activFilterMenu = menu
    }

    @IBAction func cycleFilterButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.cycleFilterMenu?.hide(animated: true)
            return
        }
        if self.activFilterButton.isSelected {
            self.activFilterButtonClicked(self.activFilterButton)
        }
        let menu = GXSelectItemsMenu(items: GXActivityManager.shared.cycleItems, multipleSelection: false)
        menu.show(to: self.contentView, style: .sheetTop, dismissBlock: {[weak self] in
            self?.cycleFilterButton.isSelected = false
        })
        menu.selected(status: self.viewModel.cycleType)
        menu.selectedAction = {[weak self] selectedItems in
            guard let item = selectedItems.first else { return }
            self?.cycleFilterButton.setTitle(item.title, for: .normal)
            self?.viewModel.cycleType = item.status
            self?.requestRefreshData()
        }
        self.cycleFilterMenu = menu
    }
}

extension GXMinePrOrderVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXMinePtOrderCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindCell(model: model)

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        let vc = GXMinePrOrderDetailVC(orderSn: model.orderSn)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
