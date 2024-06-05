//
//  GXActivitySelectItemsMenu.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import GXRefresh
import MBProgressHUD

class GXActivitySelectItemsMenu: UIView {
    private let CellID = "CellID"
    private weak var viewModel: GXMinePrOrderViewModel!

    var selectedAction: GXActionBlockItem<[GXActivityBaseInfoData]>?

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.rowHeight = 40.0
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXSelectItemCell.self)
        }
    }()

    init(height: CGFloat, viewModel: GXMinePrOrderViewModel) {
        let rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: height)
        super.init(frame: rect)

        self.viewModel = viewModel
        self.createSubviews()
        self.setNeedsUpdateConstraints()
        self.layoutIfNeeded()
    }

    func selected(data: GXActivityBaseInfoData?) {
        if let index = self.viewModel.menuList.firstIndex(where: { $0.id == data?.id }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.bottomLeft, .bottomRight], radius: 16.0)
    }

    func createSubviews() {
        self.backgroundColor = .white
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
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

        if self.viewModel.menuList.count == 0 {
            self.requestRefreshData()
        }
        else {
            self.tableView.gx_footer?.endRefreshing(isNoMore: self.viewModel.menuNoMore)
            self.selected(data: self.viewModel.activityData)
        }
    }
}

extension GXActivitySelectItemsMenu {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self)
        }
        self.viewModel.requestGetListMyActivity(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self)
            self?.tableView.gx_reloadData()
            self?.selected(data: self?.viewModel.activityData)
            completion?(true, isLastPage)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self)
            GXToast.showError(error, to: self)
            completion?(false, false)
        })
    }

    func requestRefreshData() {
        self.requestData(isRefresh: true, isShowHud: true) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }
}

extension GXActivitySelectItemsMenu: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.menuList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXSelectItemCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.menuList[indexPath.row]
        cell.textLabel?.text = model.activityName

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = self.viewModel.menuList[indexPath.row]
        self.selectedAction?([selectedItem])
        self.hide(animated: true)
    }

}

