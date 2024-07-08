//
//  GXChargingOrderDetailsVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import MBProgressHUD
import PromiseKit
import SkeletonView

class GXChargingOrderDetailsVC: GXBaseViewController {
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true, separatorLeft: false)
            tableView.separatorColor = .gx_lineGray
            tableView.sectionHeaderHeight = 10
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.register(cellType: GXChargingOrderDetailsCell0.self)
            tableView.register(cellType: GXChargingOrderDetailsCell1.self)
            tableView.register(cellType: GXChargingOrderDetailsCell2.self)
            tableView.register(cellType: GXChargingOrderDetailsCell3.self)
            tableView.register(cellType: GXChargingOrderDetailsCell4.self)
            tableView.register(cellType: GXChargingOrderDetailsCell5.self)
            tableView.register(cellType: GXChargingOrderDetailsCell6.self)
            tableView.register(cellType: GXChargingOrderDetailsCell7.self)
            tableView.register(cellType: GXChargingOrderDetailsCell8.self)
        }
    }
    
    private lazy var tableHeader: GXChargingOrderDetailsHeader = {
        let rect = CGRect(origin: .zero, size: CGSize(width: self.view.width, height: 176))
        return GXChargingOrderDetailsHeader(frame: rect)
    }()
    
    private(set) lazy var viewModel: GXChargingOrderDetailsViewModel = {
        return GXChargingOrderDetailsViewModel()
    }()
    
    override func viewDidLayoutSubviews() {
        self.view.layoutSkeletonIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestOrderConsumerStart()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Order Details"
        self.gx_addBackBarButtonItem()
        
        self.payNowButton.setBackgroundColor(.gx_green, for: .normal)
        self.payNowButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        self.tableView.tableHeaderView = self.tableHeader
        self.view.isSkeletonable = true
        self.tableView.isSkeletonable = true
    }
    
}

extension GXChargingOrderDetailsVC {
    
    func requestOrderConsumerStart() {
        self.view.showAnimatedGradientSkeleton()
        self.tableView.tableHeaderView?.showAnimatedGradientSkeleton()
        firstly {
            self.viewModel.requestOrderConsumerDetail()
        }.done { models in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.view.hideSkeleton()
                self.tableView.tableHeaderView?.hideSkeleton()
                self.tableView.reloadData()
            })
        }.catch { error in
            self.view.hideSkeleton()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
}

extension GXChargingOrderDetailsVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    // MARK - SkeletonTableViewDataSource
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.row {
        case 0:
            return GXChargingOrderDetailsCell0.reuseIdentifier
        case 1:
            return GXChargingOrderDetailsCell1.reuseIdentifier
        case 2:
            return GXChargingOrderDetailsCell2.reuseIdentifier
        case 3:
            return GXChargingOrderDetailsCell3.reuseIdentifier
        case 4:
            return GXChargingOrderDetailsCell4.reuseIdentifier
        default:
            return ""
        }
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        switch indexPath.row {
        case 0:
            let cell: GXChargingOrderDetailsCell0 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 1:
            let cell: GXChargingOrderDetailsCell1 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 2:
            let cell: GXChargingOrderDetailsCell2 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 3:
            let cell: GXChargingOrderDetailsCell3 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        case 4:
            let cell: GXChargingOrderDetailsCell4 = skeletonView.dequeueReusableCell(for: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
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
            cell.bindCell(count: 6)
            return cell
        case 2:
            let cell: GXChargingOrderDetailsCell2 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 3:
            let cell: GXChargingOrderDetailsCell3 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(count: 3)
            return cell
        case 4:
            let cell: GXChargingOrderDetailsCell4 = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(count: 4)
            return cell
        case 5:
            let cell: GXChargingOrderDetailsCell5 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 6:
            let cell: GXChargingOrderDetailsCell6 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 7:
            let cell: GXChargingOrderDetailsCell7 = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case 8:
            let cell: GXChargingOrderDetailsCell8 = tableView.dequeueReusableCell(for: indexPath)
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
        case 2: return 80
        case 3: return 156
        case 4: return 142
        case 5: return 48
        case 6: return 54
        case 7: return 110
        case 8: return 146
        default: return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension GXChargingOrderDetailsVC {
    
    @IBAction func appealButtonClicked(_ sender: Any?) {
        
    }
    
    @IBAction func payNowButtonClicked(_ sender: Any?) {
        
    }
    
}
