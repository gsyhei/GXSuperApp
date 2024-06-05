//
//  GXParticipantHomeMysignListVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/2/6.
//

import UIKit

class GXParticipantHomeMysignListVC: GXBaseViewController {
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .gx_background
            $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            $0.separatorStyle = .none
            $0.placeholder = "暂无活动"
            $0.rowHeight = 136.0
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXPrHomeActivityPageCell.self)
        }
    }()
    var list: [GXActivityBaseInfoData] = []

    init(list: [GXActivityBaseInfoData]) {
        super.init(nibName: nil, bundle: nil)
        self.list = list
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.gx_reloadData()
    }
}

extension GXParticipantHomeMysignListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPrHomeActivityPageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(model: self.list[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let pageCell = cell as? GXPrHomeActivityPageCell else { return }
        GXBaseTableView.setTableView(tableView, roundView: pageCell.containerView, at: indexPath)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.list[indexPath.row]
        GXApiUtil.requestCreateEvent(targetType: 4, targetId: model.id)
        let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
