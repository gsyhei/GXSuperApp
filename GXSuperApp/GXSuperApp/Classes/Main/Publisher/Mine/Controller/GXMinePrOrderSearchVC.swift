//
//  GXMinePrOrderSearchVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit
import RxCocoaPlus
import MBProgressHUD
import GXRefresh

let GXMinePrOrderSearchVCHeroId = "search"
class GXMinePrOrderSearchVC: GXBaseViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: GXBaseTableView!
    var selectedAction: GXActionBlockItem<GXListMyOrderItem>?

    private lazy var viewModel: GXMinePrOrderSearchViewModel = {
        return GXMinePrOrderSearchViewModel()
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.hero.isEnabled = true
        if !self.didGetNetworktLoad {
            self.searchTextField.becomeFirstResponder()
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.hero.id = GXMinePrOrderSearchVCHeroId
    }

    override func setupViewController() {

        self.searchTextField.delegate = self
        (self.searchTextField.rx.textInput <-> self.viewModel.searchWord).disposed(by: disposeBag)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        self.tableView.rowHeight = 148.0
        self.tableView.placeholder = "暂无搜索的订单"
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

extension GXMinePrOrderSearchVC {
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

extension GXMinePrOrderSearchVC {
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.searchTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
}

extension GXMinePrOrderSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard self.viewModel.searchWord.value?.count ?? 0 > 0 else {
            return true
        }
        self.requestRefreshData()
        return true
    }
}

extension GXMinePrOrderSearchVC: UITableViewDataSource, UITableViewDelegate {
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
        self.navigationController?.hero.isEnabled = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
