//
//  GXPtQuestionnaireListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/31.
//

import UIKit
import MBProgressHUD

class GXPtQuestionnaireListVC: GXBaseViewController {

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.dataSource = self
            $0.delegate = self
            $0.placeholder = "暂无问卷调查"
            $0.register(cellType: GXPtQuestionnaireListCell.self)
            $0.register(headerFooterViewType: GXPublishEventListHeader.self)
        }
    }()

    private var activityId: Int = 0
    private var questionaireRunList: [GXPublishQuestionaireDetailData] = []
    private var questionaireEndList: [GXPublishQuestionaireDetailData] = []

    required init(activityId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.activityId = activityId
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.didGetNetworktLoad {
            self.requestGetActivityQuestionaireInfo(isShowHud: false)
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetActivityQuestionaireInfo()
    }

    override func setupViewController() {
        self.title = "问卷调查"
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

extension GXPtQuestionnaireListVC {

    /// 获取活动问卷
    func requestGetActivityQuestionaireInfo(isShowHud: Bool = true) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.activityId
        params["shelfStatus"] = 1
        let api = GXApi.normalApi(Api_CActivity_GetActivityQuestionaireInfo, params, .get)
        GXNWProvider.login_request(api, type: GXActivityQuestionaireInfoModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            self.questionaireRunList.removeAll()
            self.questionaireEndList.removeAll()
            if let questList = model.data?.activityQuestionaires?.list {
                for item in questList {
                    if item.questionaireStatus == 3 {
                        self.questionaireRunList.append(item)
                    }
                    else {
                        self.questionaireEndList.append(item)
                    }
                }
            }
            MBProgressHUD.dismiss(for: self.view)
            self.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

}

extension GXPtQuestionnaireListVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.questionaireRunList.count > 0 {
            return 2
        }
        if self.questionaireEndList.count > 0 {
            return 2
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.questionaireRunList.count
        }
        else {
            return self.questionaireEndList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPtQuestionnaireListCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 0 {
            let model = self.questionaireRunList[indexPath.row]
            cell.bindCell(model: model, isHiddenEndStatus: true)
            cell.attendAction = {[weak self] curCell in
                guard let `self` = self else { return }
                guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
                let curModel = self.questionaireRunList[curIndexPath.row]
                let vc = GXPtQuestionnaireSubmitVC.createVC(questionaireData: curModel)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            let model = self.questionaireEndList[indexPath.row]
            cell.bindCell(model: model, isHiddenEndStatus: true)
            cell.attendAction = {[weak self] curCell in
                guard let `self` = self else { return }
                guard let curIndexPath = self.tableView.indexPath(for: curCell) else { return }
                let curModel = self.questionaireEndList[curIndexPath.row]
                let vc = GXPtQuestionnaireSubmitVC.createVC(questionaireData: curModel)
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

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView().then {
                $0.backgroundColor = .gx_background
            }
        }
        return nil
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
