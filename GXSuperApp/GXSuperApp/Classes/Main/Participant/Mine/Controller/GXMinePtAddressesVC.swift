//
//  GXMinePtAddressesVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import GXRefresh
import MBProgressHUD

class GXMinePtAddressesVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var addButton: UIButton!

    private var viewModel: GXMinePtAddressesViewModel = {
        return GXMinePtAddressesViewModel()
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.didGetNetworktLoad {
            self.requestRefreshData(isShowHud: self.viewModel.list.count == 0)
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData(isShowHud: true)
    }

    override func setupViewController() {
        self.title = "我的地址"
        self.view.backgroundColor = .white
        self.gx_addBackBarButtonItem()

        self.tableView.placeholder = "暂无地址"
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
        self.tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        self.tableView.sectionHeaderHeight = 16.0
        self.tableView.sectionFooterHeight = .leastNormalMagnitude
        self.tableView.rowHeight = 110.0
        self.tableView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.tableView.register(cellType: GXMinePtAddressCell.self)
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

extension GXMinePtAddressesVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetUserAddressPage(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
            completion?(true, isLastPage)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            completion?(false, false)
        })
    }

    func requestRefreshData(isShowHud: Bool = true) {
        self.requestData(isRefresh: true, isShowHud: isShowHud) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }
    
    func requestAddressDeleteById(index: Int) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestAddressDeleteById(index: index, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestSetDefaultAddress(index: Int) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSetDefaultAddress(index: index, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXMinePtAddressesVC {
    @IBAction func addButtonClicked(_ sender: UIButton) {
        let vc = GXMinePtAddressEditVC.createVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension GXMinePtAddressesVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXMinePtAddressCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.section]
        cell.bindCell(model: model)

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.viewModel.list[indexPath.section]
        let vc = GXMinePtAddressEditVC.createVC(data: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除", handler: { (action, view, completion) in
            GXUtil.showAlert(title: "确定删除该地址？", actionTitle: "确定") { alert, index in
                completion(true)
                guard index == 1 else { return }
                self.requestAddressDeleteById(index: indexPath.section)
            }
        })
        let defaultAction = UIContextualAction(style: .normal, title: "设置默认", handler: { (action, view, completion) in
            completion(true)
            self.requestSetDefaultAddress(index: indexPath.section)
        })
        defaultAction.backgroundColor = .gx_black

        return UISwipeActionsConfiguration(actions: [deleteAction, defaultAction])
    }
}
