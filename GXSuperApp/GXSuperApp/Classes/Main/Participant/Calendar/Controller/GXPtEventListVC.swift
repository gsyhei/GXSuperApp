//
//  GXPtEventListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import MBProgressHUD

class GXPtEventListVC: GXBaseViewController {

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.placeholder = "暂无事件"
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXPtEventListCell.self)
            $0.register(headerFooterViewType: GXPublishEventListHeader.self)
        }
    }()

    private var activityId: Int = 0
    private var infoData: GXActivityEventInfoData?

    required init(activityId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.activityId = activityId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetActivityEventInfo()
    }
    
    override func setupViewController() {
        self.title = "事件"
        self.gx_addBackBarButtonItem()

        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension GXPtEventListVC {

    func requestGetActivityEventInfo() {
        MBProgressHUD.showLoading(to: self.view)
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        let api = GXApi.normalApi(Api_CActivity_GetActivityEventInfo, params, .get)
        GXNWProvider.login_request(api, type: GXActivityEventInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.infoData = model.data
            self.tableView.gx_reloadData()
            MBProgressHUD.dismiss(for: self.view)
        }) {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }

}

extension GXPtEventListVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.infoData?.activityEvents.count ?? 0 > 0 {
            return 2
        }
        if self.infoData?.finishedActivityEvents.count ?? 0 > 0 {
            return 2
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.infoData?.activityEvents.count ?? 0
        }
        else {
            return self.infoData?.finishedActivityEvents.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPtEventListCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 0 {
            let model = self.infoData?.activityEvents[indexPath.row]
            cell.bindCell(model: model)
        }
        else {
            let model = self.infoData?.finishedActivityEvents[indexPath.row]
            cell.bindCell(model: model)
        }
        cell.attendAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
            if indexPath.section == 0 {
                guard let curModel = self.infoData?.activityEvents[curIndexPath.row] else { return }
                let vc = GXPtEventDetailVC.createVC(eventData: curModel)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                guard let curModel = self.infoData?.finishedActivityEvents[curIndexPath.row] else { return }
                let vc = GXPtEventDetailVC.createVC(eventData: curModel)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXPublishEventListHeader.self)
        if section == 0 {
            header?.updateStatus(isEnd: false)
        }
        else {
            header?.updateStatus(isEnd: true)
        }
        return header
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
