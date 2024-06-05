//
//  GXPublishQuestStatsVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/7.
//

import UIKit

class GXPublishQuestStatsVC: GXBaseViewController {
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXPublishQuestStatsCell.self)
            $0.register(headerFooterViewType: GXPublishQuestStatsHeader.self)
        }
    }()
    
    var reportData: GXQuestionaireReportData?

    required init(reportData: GXQuestionaireReportData?) {
        super.init(nibName: nil, bundle: nil)
        self.reportData = reportData
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateReportData(_ reportData: GXQuestionaireReportData?) {
        self.reportData = reportData
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
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

extension GXPublishQuestStatsVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.reportData?.topicReports.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reportData?.topicReports[section].optionReports.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishQuestStatsCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.reportData?.topicReports[indexPath.section].optionReports[indexPath.row]
        cell.bindCell(model: model)

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXPublishQuestStatsHeader.self)
        let model = self.reportData?.topicReports[section]
        header?.bindView(model: model, section: section)
        return header
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 86.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
