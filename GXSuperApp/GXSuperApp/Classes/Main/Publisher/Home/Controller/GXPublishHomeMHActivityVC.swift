//
//  GXPublishHomeMHActivityVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit
import GXRefresh
import MBProgressHUD

class GXPublishHomeMHActivityVC: GXBaseViewController {
    private var statusMenu: GXSelectItemsMenu?
    private var addedStatusMenu: GXSelectItemsMenu?

    lazy var topContentView: UIView = {
        return UIView().then {
            $0.backgroundColor = .white
        }
    }()

    lazy var activityStatusButton: GXArrowButton = {
        return GXArrowButton(type: .custom).then {
            $0.contentHorizontalAlignment = .center
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 120, height: 40))
            $0.setTitle("活动状态", for: .normal)
            $0.setTitleColor(.gx_textBlack, for: .normal)
            $0.setImage(UIImage(named: "pr_wz_arraw"), for: .normal)
            $0.titleLabel?.font = .gx_font(size: 14)
            $0.addTarget(self, action: #selector(activityStatusButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    lazy var activityAddedStatusButton: GXArrowButton = {
        return GXArrowButton(type: .custom).then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 120, height: 40))
            $0.contentHorizontalAlignment = .center
            $0.setTitle("上下架状态", for: .normal)
            $0.setTitleColor(.gx_textBlack, for: .normal)
            $0.setImage(UIImage(named: "pr_wz_arraw"), for: .normal)
            $0.titleLabel?.font = .gx_font(size: 14)
            $0.addTarget(self, action: #selector(activityAddedStatusButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    lazy var contentView: UIView = {
        return UIView().then {
            $0.backgroundColor = .white
        }
    }()

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.rowHeight = 170.0
            $0.dataSource = self
            $0.delegate = self
            $0.placeholder = "暂⽆协助的活动"
            $0.register(cellType: GXPublishActivityCell.self)
        }
    }()

    private lazy var viewModel: GXPublishHomeMHActivityViewModel = {
        return GXPublishHomeMHActivityViewModel()
    }()

    required init(calendarModel: GXHorizontalCalendarDaysModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.calendarModel = calendarModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.activityStatusButton.imageLocationAdjust(model: .right, spacing: 0)
        self.activityAddedStatusButton.imageLocationAdjust(model: .right, spacing: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.didGetNetworktLoad {
            self.requestRefreshData(isShowHud: false)
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
        NotificationCenter.default.rx
            .notification(GX_NotifName_Login)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.requestRefreshData()
            }).disposed(by: disposeBag)
    }

    override func setupViewController() {
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.tableView)
        self.view.addSubview(self.topContentView)
        self.topContentView.addSubview(self.activityStatusButton)
        self.topContentView.addSubview(self.activityAddedStatusButton)

        self.topContentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(42)
        }
        self.activityStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(36)
        }
        self.activityAddedStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalTo(self.activityStatusButton.snp.right).offset(10)
            make.height.equalTo(36)
        }
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.topContentView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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

        NotificationCenter.default.rx
            .notification(GX_NotifName_HCalendarSelected)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.requestRefreshData()
            }).disposed(by: disposeBag)
    }

    func hideMenu() {
        if self.activityAddedStatusButton.isSelected {
            self.activityAddedStatusButtonClicked(self.activityAddedStatusButton)
        }
        if self.activityStatusButton.isSelected {
            self.activityStatusButtonClicked(self.activityStatusButton)
        }
    }

    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetListMyActivity(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
            completion?(true, isLastPage)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            self?.tableView.gx_reloadData()
            completion?(false, false)
        })
    }

    func requestRefreshData(isShowHud: Bool = true) {
        self.requestData(isRefresh: true, isShowHud: isShowHud) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }

}

extension GXPublishHomeMHActivityVC {

    @objc func activityStatusButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.statusMenu?.hide(animated: true)
            return
        }

        if self.activityAddedStatusButton.isSelected {
            self.activityAddedStatusButtonClicked(self.activityAddedStatusButton)
        }
        let items: [GXSelectItem] = {
            return [
                GXSelectItem("全部", nil),
                GXSelectItem("进行中", 3),
                GXSelectItem("已结束", 4),
                GXSelectItem("未开始", 2),
            ]
        }()
        let menu = GXSelectItemsMenu(items: items, multipleSelection: true)
        menu.show(to: self.contentView, style: .sheetTop, dismissBlock: {[weak self] in
            self?.activityStatusButton.isSelected = false
        })
        menu.selected(items: self.viewModel.activityStatusList)
        menu.selectedAction = {[weak self] selectedItems in
            var list: [String] = []
            for item in selectedItems {
                guard let status = item.status else { continue }
                list.append("\(status)")
            }
            self?.viewModel.activityStatusList = list
            self?.requestRefreshData()
        }
        self.statusMenu = menu
    }

    @objc func activityAddedStatusButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            self.addedStatusMenu?.hide(animated: true)
            return
        }

        if self.activityStatusButton.isSelected {
            self.activityStatusButtonClicked(self.activityStatusButton)
        }
        let items: [GXSelectItem] = {
            return [
                GXSelectItem("全部", nil),
                GXSelectItem("已上架", 1),
                GXSelectItem("已下架", 0),
                GXSelectItem("平台禁用", 2)
            ]
        }()
        let menu = GXSelectItemsMenu(items: items, multipleSelection: false)
        menu.show(to: self.contentView, style: .sheetTop, dismissBlock: {[weak self] in
            self?.activityAddedStatusButton.isSelected = false
        })
        menu.selected(status: self.viewModel.shelfStatus)
        menu.selectedAction = {[weak self] selectedItems in
            self?.viewModel.shelfStatus = selectedItems.first?.status
            self?.requestRefreshData()
        }
        self.addedStatusMenu = menu
    }

}

extension GXPublishHomeMHActivityVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishActivityCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindModel(model: model)
        cell.eventAction = {[weak self] curModel in
            guard let `self` = self else { return }
            guard let activityData = curModel else { return }
            let vc = GXPublishEventListVC(activityData: activityData)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        let vc = GXPublishActivityDetailVC.createVC(activityId: model.id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
