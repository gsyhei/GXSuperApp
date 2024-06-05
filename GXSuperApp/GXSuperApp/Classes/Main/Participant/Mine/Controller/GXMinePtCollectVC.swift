//
//  GXMinePtCollectVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit
import MBProgressHUD
import GXRefresh

class GXMinePtCollectVC: GXBaseViewController {
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
            $0.backgroundColor = .gx_background
            $0.placeholder = "暂无收藏"
            $0.separatorStyle = .none
            $0.rowHeight = 170.0
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXPrHomeActivityPageCell.self)
        }
    }()

    private var viewModel: GXMinePtCollectViewModel = {
        return GXMinePtCollectViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
    }
    
    override func setupViewController() {
        self.title = "我的收藏"
        self.view.backgroundColor = .white
        self.gx_addBackBarButtonItem()

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalToSuperview()
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

}

extension GXMinePtCollectVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetListMyFavorite(refresh: isRefresh, success: {[weak self] isLastPage in
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

extension GXMinePtCollectVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let pageCell = cell as? GXPrHomeActivityPageCell else { return }
        GXBaseTableView.setTableView(tableView, roundView: pageCell.containerView, at: indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPrHomeActivityPageCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindCell(model: model)

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
