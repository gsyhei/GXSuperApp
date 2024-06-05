//
//  GXPublishHomeMDActivityVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit
import GXRefresh
import MBProgressHUD

class GXPublishHomeMDActivityVC: GXBaseViewController {

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.rowHeight = 138.0
            $0.dataSource = self
            $0.delegate = self
            $0.placeholder = "暂⽆草稿"
            $0.register(cellType: GXPublishDraftCell.self)
        }
    }()

    private lazy var viewModel: GXPublishHomeMDActivityViewModel = {
        return GXPublishHomeMDActivityViewModel()
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
        NotificationCenter.default.rx
            .notification(GX_NotifName_Login)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.requestRefreshData()
            }).disposed(by: disposeBag)
    }

    override func setupViewController() {
        self.view.addSubview(self.tableView)
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
            completion?(false, false)
        })
    }

    func requestRefreshData(isShowHud: Bool = true) {
        self.requestData(isRefresh: true, isShowHud: isShowHud) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }

    func requestActivityDelete(indexPath: IndexPath) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestActivityDelete(index: indexPath.row, success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.tableView.updateWithBlock { 
                $0?.deleteRow(at: indexPath, with: .left)
            }
            GXToast.showSuccess(text: "草稿已删除")
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error)
        })
    }

}

extension GXPublishHomeMDActivityVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishDraftCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindModel(model: model)
        cell.deleteAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            GXUtil.showAlert(title: "确认删除草稿？", actionTitle: "确定") { alert, index in
                guard index == 1 else { return }
                self.requestActivityDelete(indexPath: curIndexPath)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        let vc = GXPublishStep1VC.createVC(type: .draft, activityId: model.id)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

