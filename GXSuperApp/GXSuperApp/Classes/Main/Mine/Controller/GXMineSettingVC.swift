//
//  GXMineSettingVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import MBProgressHUD
import Kingfisher

class GXMineSettingVC: GXBaseViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(separatorLeft: false)
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            tableView.sectionHeaderHeight = .leastNormalMagnitude
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.rowHeight = 54
            tableView.separatorColor = .gx_lineGray
            tableView.register(cellType: GXMineDefaultCell.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.navigationItem.title = "Settings"
        self.gx_addBackBarButtonItem()
    }

}

extension GXMineSettingVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXMineDefaultCell = tableView.dequeueReusableCell(for: indexPath)
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Payment Management"
        case 1:
            cell.titleLabel.text = "Account Management"
        case 2:
            cell.titleLabel.text = "Clear Cache"
        case 3:
            cell.titleLabel.text = "Version Number"
            cell.detailLabel.text = "v" + (UIApplication.appVersion() ?? "")
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        GXBaseTableView.setTableView(tableView, cell: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let vc = GXMinePayManagerVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = GXMineAccountManagerVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            MBProgressHUD.showLoading()
            KingfisherManager.shared.cache.clearDiskCache {
                MBProgressHUD.dismiss()
                let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? GXMineDefaultCell
                cell?.detailLabel.text = "Cleared"
                GXToast.showSuccess(text: "Cleared")
            }
        case 3:
            break
        default: break
        }
    }
    
}
