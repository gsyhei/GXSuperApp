//
//  GXChargingOrderDetailsVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit

class GXChargingOrderDetailsVC: GXBaseViewController {
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var tableView: GXBaseTableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.sectionHeaderHeight = 10
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.register(cellType: GXChargingOrderDetailsCell0.self)
            tableView.register(cellType: GXChargingOrderDetailsCell1.self)            
        }
    }
    
    private lazy var tableHeader: GXChargingOrderDetailsHeader = {
        let rect = CGRect(origin: .zero, size: CGSize(width: self.view.width, height: 176))
        return GXChargingOrderDetailsHeader(frame: rect)
    }()
    
    private(set) lazy var viewModel: GXChargingOrderDetailsViewModel = {
        return GXChargingOrderDetailsViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Order Details"
        self.gx_addBackBarButtonItem()
        
        self.payNowButton.setBackgroundColor(.gx_green, for: .normal)
        self.payNowButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        self.tableView.tableHeaderView = self.tableHeader
    }
    
}

extension GXChargingOrderDetailsVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionIndexs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.sectionIndexs[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = self.viewModel.sectionIndexs[indexPath.section][indexPath.row]
        switch index {
        case 0:
            let cell: GXChargingOrderDetailsCell0 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 1:
            let cell: GXChargingOrderDetailsCell1 = tableView.dequeueReusableCell(for: indexPath)
            cell.updateCell(type: 2)
            return cell
        default: return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        GXBaseTableView.setTableView(tableView, cell: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = self.viewModel.sectionIndexs[indexPath.section][indexPath.row]
        switch index {
        case 0: return 44
        case 1: return 200
        default: return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}

extension GXChargingOrderDetailsVC {
    
    @IBAction func appealButtonClicked(_ sender: Any?) {
        
    }
    
    @IBAction func payNowButtonClicked(_ sender: Any?) {
        
    }
    
}
