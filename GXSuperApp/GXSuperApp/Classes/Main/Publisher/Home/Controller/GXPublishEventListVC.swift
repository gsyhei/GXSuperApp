//
//  GXPublishEventListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import MBProgressHUD

class GXPublishEventListVC: GXBaseViewController {

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.dataSource = self
            $0.delegate = self
            $0.placeholder = "暂无事件"
            $0.setAddButton(title: "添加事件") {[weak self] in
                guard let `self` = self else { return }
                let vc = GXPublishEventStepVC.createVC(activityData: self.viewModel.activityData)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            $0.register(cellType: GXPublishEventListCell.self)
            $0.register(headerFooterViewType: GXPublishEventListHeader.self)
        }
    }()

    private lazy var addButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.contentHorizontalAlignment = .right
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
            $0.setTitle("添加事件", for: .normal)
            $0.setTitleColor(.gx_black, for: .normal)
            $0.setTitleColor(.gx_lightGray, for: .highlighted)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.setImage(UIImage(named: "aw_add"), for: .normal)
            $0.addTarget(self, action: #selector(self.rightButtonItemTapped), for: .touchUpInside)
        }
    }()

    private lazy var viewModel: GXPublishEventListViewModel = {
        return GXPublishEventListViewModel()
    }()

    required init(activityData: GXActivityBaseInfoData) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.activityData = activityData
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestGetActivityEventInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.title = "事件"
        self.gx_addBackBarButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.addButton)

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

extension GXPublishEventListVC {
    
    func requestGetActivityEventInfo() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetActivityEventInfo(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.tableView.gx_reloadData()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

}

extension GXPublishEventListVC {

    @objc func rightButtonItemTapped() {
        let vc = GXPublishEventStepVC.createVC(activityData: self.viewModel.activityData)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension GXPublishEventListVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.viewModel.infoData?.activityEvents.count ?? 0 > 0 {
            return 2
        }
        if self.viewModel.infoData?.finishedActivityEvents.count ?? 0 > 0 {
            return 2
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.viewModel.infoData?.activityEvents.count ?? 0
        }
        else {
            return self.viewModel.infoData?.finishedActivityEvents.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishEventListCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 0 {
            let model = self.viewModel.infoData?.activityEvents[indexPath.row]
            cell.bindCell(model: model)
        }
        else {
            let model = self.viewModel.infoData?.finishedActivityEvents[indexPath.row]
            cell.bindCell(model: model)
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
        if indexPath.section == 0 {
            let model = self.viewModel.infoData?.activityEvents[indexPath.row]
            let vc = GXPublishEventStepVC.createVC(activityData: self.viewModel.activityData, eventId: model?.id)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let model = self.viewModel.infoData?.finishedActivityEvents[indexPath.row]
            let vc = GXPublishEventStepVC.createVC(activityData: self.viewModel.activityData, eventId: model?.id)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
