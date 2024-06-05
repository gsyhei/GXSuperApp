//
//  GXMinePrWalletVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/12.
//

import UIKit
import MBProgressHUD
import GXRefresh

class GXMinePrWalletVC: GXBaseViewController {
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var enableBalanceLabel: UILabel!
    @IBOutlet weak var frozenBalanceLabel: UILabel!

    private lazy var viewModel: GXMinePrWalletViewModel = {
        return GXMinePrWalletViewModel()
    }()

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
    }

    override func setupViewController() {
        self.title = "我的钱包"
        self.gx_addBackBarButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "申请提现", style: .plain, target: self, action: #selector(rightBarButtonItemTapped))

        self.tableView.rowHeight = 62.0
        self.tableView.placeholder = "暂无提现记录"
        self.tableView.register(cellType: GXMinePrWalletCell.self)
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

extension GXMinePrWalletVC {
    @objc func rightBarButtonItemTapped() {
        guard let data = self.viewModel.data else { return }

        if data.frozenBalance > 0 {
            let message = "您有一个申请正在处理中审核通过后，可再次发起新的提现申请"
            GXUtil.showAlert(to: self.view, title: message, cancelTitle: "我知道了")
            return
        }
        let vc = GXMinePrWithdrawVC.createVC(data: data)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func updateTopView() {
        self.enableBalanceLabel.text = String(format: "%.2f", self.viewModel.data?.enableBalance ?? 0)
        self.frozenBalanceLabel.text = String(format: "%.2f", self.viewModel.data?.frozenBalance ?? 0)
    }
}

extension GXMinePrWalletVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetMyWallet(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateTopView()
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
}

extension GXMinePrWalletVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXMinePrWalletCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindCell(model: model)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        // 委托类型 0-订单收入 1-提现 2-其它
        // businessFlag
        if model.businessFlag == 0 {
            let vc = GXMinePrOrderDetailVC(orderSn: model.orderSn)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if model.businessFlag == 1 {
            let vc = GXMinePrWithdrawDetailVC.createVC(item: model)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
