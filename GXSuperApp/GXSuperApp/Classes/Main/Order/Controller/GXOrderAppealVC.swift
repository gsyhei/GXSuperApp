//
//  GXOrderAppealVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import MBProgressHUD
import PromiseKit

class GXOrderAppealVC: GXBaseViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(estimated: true, separatorLeft: false)
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 12))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            tableView.backgroundColor = .gx_background
            tableView.separatorColor = .gx_lineGray
            tableView.sectionHeaderHeight = 10
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.register(cellType: GXChargingOrderDetailsCell1.self)
            tableView.register(cellType: GXChargingOrderDetailsCell2.self)
            tableView.register(cellType: GXChargingOrderDetailsCell3.self)
            tableView.register(cellType: GXChargingOrderDetailsCell4.self)
            tableView.register(cellType: GXChargingOrderDetailsCell5.self)
            tableView.register(cellType: GXOrderAppealCell.self)
        }
    }
    
    private(set) lazy var viewModel: GXOrderAppealViewModel = {
        return GXOrderAppealViewModel()
    }()
    
    class func createVC(model: GXChargingOrderDetailCellModel) -> GXOrderAppealVC {
        return GXOrderAppealVC.xibViewController().then {
            $0.hidesBottomBarWhenPushed = true
            $0.viewModel.detailCellModel = model
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestDictListAvailable()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Order Appeal"
        self.gx_addBackBarButtonItem()
        
        self.submitButton.setBackgroundColor(.gx_gray, for: .disabled)
        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.submitButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        self.submitButton.isEnabled = false
    }

}

private extension GXOrderAppealVC {
    func requestDictListAvailable() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestDictListAvailable()
        }.done { model in
            MBProgressHUD.dismiss()
            self.tableView.reloadData()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
}

extension GXOrderAppealVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXOrderAppealCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindCell(superVC: self) {[weak self] isSubmit in
            guard let `self` = self else { return }
            self.submitButton.isEnabled = isSubmit
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        GXBaseTableView.setTableView(tableView, cell: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 444.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
