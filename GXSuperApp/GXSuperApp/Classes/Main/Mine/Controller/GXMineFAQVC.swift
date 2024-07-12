//
//  GXMineFAQVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/13.
//

import UIKit
import MBProgressHUD

class GXMineFAQVC: GXBaseViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration()
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            tableView.sectionHeaderHeight = 12
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.rowHeight = 54
            tableView.register(cellType: GXMineDefaultCell.self)
        }
    }
    var list: [GXQuestionsConsumerListData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestQuestionsConsumerList()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "FAQ"
        self.gx_addBackBarButtonItem()
        
    }
    
}

private extension GXMineFAQVC {
    func requestQuestionsConsumerList() {
        MBProgressHUD.showLoading()
        let api = GXApi.normalApi(Api_questions_consumer_list, [:], .get)
        GXNWProvider.login_request(api, type: GXQuestionsConsumerListModel.self, success: { model in
            self.list = model.data
            self.tableView.reloadData()
            MBProgressHUD.dismiss()
        }, failure: { error in
            MBProgressHUD.dismiss()
            GXToast.showError(error)
        })
    }
}

extension GXMineFAQVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXMineDefaultCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.list[indexPath.section]
        cell.titleLabel.text = model.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        GXBaseTableView.setTableView(tableView, cell: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.list[indexPath.section]

    }
    
}
