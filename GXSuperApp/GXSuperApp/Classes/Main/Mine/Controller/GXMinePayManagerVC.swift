//
//  GXMinePayManagementVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit

class GXMinePayManagerVC: GXBaseViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(separatorLeft: false)
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            tableView.sectionHeaderHeight = 12.0
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.register(cellType: GXMinePayManagerCell.self)
            tableView.register(cellType: GXMineDefaultCell.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.navigationItem.title = "Payment Management"
        self.gx_addBackBarButtonItem()
    }
    
}

extension GXMinePayManagerVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: GXMinePayManagerCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(isActivate: true)
            return cell
        case 1:
            let cell: GXMineDefaultCell = tableView.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = "Wallet Balance Payme"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 80
        case 1: return 54
        default: return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        GXBaseTableView.setTableView(tableView, cell: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0: break
        case 1:
            break
        default: break
        }
    }
    
}
