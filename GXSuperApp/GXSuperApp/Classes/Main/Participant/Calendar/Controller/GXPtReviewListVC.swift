//
//  GXPtReviewListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/31.
//

import UIKit
import MBProgressHUD
import GXRefresh
import XCGLogger

class GXPtReviewListVC: GXBaseViewController {

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.placeholder = "暂无回顾"
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXPtReviewListCell.self)
        }
    }()

    private lazy var viewModel: GXPtReviewListViewModel = {
        return GXPtReviewListViewModel()
    }()

    required init(activityId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.activityId = activityId
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
        GXApiUtil.requestCreateEvent(targetType: 13, activityId: self.viewModel.activityId)
    }

    override func setupViewController() {
        self.title = "回顾"
        self.gx_addBackBarButtonItem()

        self.view.backgroundColor = .white
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

extension GXPtReviewListVC {

    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetActivityReviewInfo(refresh: isRefresh, success: {[weak self] isLastPage in
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

    func showReportSheet(chatId: Int) {
        let view = GXReportPickerView.xibView().then {
            $0.backgroundColor = .white
            $0.frame = CGRect(origin: .zero, size: CGSize(width: self.view.width, height: 320))
            $0.completion = { list in
                let listStr = list.joined(separator: ",")
                GXApiUtil.requestCreateReportViolation(chatId: chatId, chatType: 1, reportingReason: listStr)
            }
        }
        view.show(to: self.view, style: .sheetBottom, usingSpring: true)
    }
}

extension GXPtReviewListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPtReviewListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.viewModel.list[indexPath.row])
        cell.avatarAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            guard let userId = self.viewModel.list[curIndexPath.row].userId else { return }
            GXMinePtOtherVC.push(fromVC: self, userId: String(userId))
        }
        cell.moreAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            guard let chatId = self.viewModel.list[curIndexPath.row].id else { return }
            self.showReportSheet(chatId: chatId)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GXPtReviewListCell.heightCell(model: self.viewModel.list[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

