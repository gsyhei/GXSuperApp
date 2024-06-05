//
//  GXTicketsListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import UIKit
import GXRefresh
import MBProgressHUD
import HXPhotoPicker

class GXTicketsListVC: GXBaseViewController {
    
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
            $0.backgroundColor = .gx_background
            $0.separatorStyle = .none
            $0.placeholder = "暂无门票"
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXTicketsListCell.self)
        }
    }()

    private lazy var viewModel: GXTicketsListViewModel = {
        return GXTicketsListViewModel()
    }()

    required init(ticketStatus: Int, isAllOpen: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.ticketStatus = ticketStatus
        self.viewModel.isAllOpen = isAllOpen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
    }
    
    override func setupViewController() {
        self.view.backgroundColor = .gx_background
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

extension GXTicketsListVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetListMyTicket(refresh: isRefresh, success: {[weak self] isLastPage in
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

extension GXTicketsListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXTicketsListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.viewModel.list[indexPath.row], ticketStatus: self.viewModel.ticketStatus)
        let isSelected = self.viewModel.selectedIndexPaths.contains(where: {$0 == indexPath})
        cell.checked = self.viewModel.isAllOpen ? !isSelected : isSelected
        cell.openAction = {[weak self] curCell, isSelected in
            self?.openAction(cell: curCell, isSelected: isSelected)
        }
        cell.openQrcodeAction = {[weak self] curCell, image in
            self?.openQrcodeAction(cell: curCell, image: image)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isSelected = self.viewModel.selectedIndexPaths.contains(where: {$0 == indexPath})
        let isOpen = self.viewModel.isAllOpen ? !isSelected : isSelected
        if isOpen {
            return 446.0
        }
        return 220.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.viewModel.list[indexPath.row]
        let vc = GXParticipantActivityDetailVC.createVC(activityId: model.activityId)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func openAction(cell: GXTicketsListCell, isSelected: Bool) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        if self.viewModel.selectedIndexPaths.contains(where: {$0 == indexPath}) {
            self.viewModel.selectedIndexPaths.removeAll(where: {$0 == indexPath})
        }
        else {
            self.viewModel.selectedIndexPaths.append(indexPath)
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    func openQrcodeAction(cell: GXTicketsListCell, image: UIImage) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: 0, transitionalImage: image) {
            return 1
        } assetForIndex: {_ in 
            return PhotoAsset(localImageAsset: LocalImageAsset(image: image))
        } transitionAnimator: { index in
            return cell.qrcodeImageView
        }
    }
}
