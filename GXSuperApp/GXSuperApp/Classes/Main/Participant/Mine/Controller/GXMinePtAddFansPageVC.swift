//
//  GXMinePtAddFansPageVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit
import MBProgressHUD
import GXRefresh

class GXMinePtAddFansPageVC: GXBaseViewController {
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
            $0.backgroundColor = .gx_background
            $0.separatorStyle = .none
            $0.rowHeight = 88.0
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXMinePtAddFansPageCell.self)
        }
    }()

    private var viewModel: GXMinePtAddFansViewModel = {
        return GXMinePtAddFansViewModel()
    }()
    
    required init(selectIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.selectIndex = selectIndex
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
    }
    
    override func setupViewController() {
        if self.viewModel.selectIndex == 0 {
            self.tableView.placeholder = "暂无粉丝"
        } else {
            self.tableView.placeholder = "暂无关注"
        }
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
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

extension GXMinePtAddFansPageVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetList(refresh: isRefresh, success: {[weak self] isLastPage in
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

    func requestFollowUser(index: Int) {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestFollowUser(index: index, success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXMinePtAddFansPageVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let pageCell = cell as? GXMinePtAddFansPageCell else { return }
        GXBaseTableView.setTableView(tableView, roundView: pageCell.containerView, at: indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXMinePtAddFansPageCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindCell(model: model, isMyFans: self.viewModel.selectIndex == 0)
        cell.attentionAction = {[weak self] curCell in
            self?.attentionAction(cell: curCell)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.viewModel.list[indexPath.row]
        GXMinePtOtherVC.push(fromVC: self, userId: model.id)
    }

    func attentionAction(cell: GXMinePtAddFansPageCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let model = self.viewModel.list[indexPath.row]
        
        if self.viewModel.selectIndex == 0 {
            if model.followEachOther {
                GXUtil.showAlert(title: "确认不再关注？", actionTitle: "确定") { alert, index in
                    guard index == 1 else { return }
                    self.requestFollowUser(index: indexPath.row)
                }
            } else {
                self.requestFollowUser(index: indexPath.row)
            }
        }
        else {
            if model.isDelete {
                self.requestFollowUser(index: indexPath.row)
            }
            else {
                GXUtil.showAlert(title: "确认不再关注？", actionTitle: "确定") { alert, index in
                    guard index == 1 else { return }
                    self.requestFollowUser(index: indexPath.row)
                }
            }
        }
    }
}
