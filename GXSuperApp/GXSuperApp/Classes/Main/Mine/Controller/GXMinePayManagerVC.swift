//
//  GXMinePayManagementVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import MBProgressHUD
import PromiseKit
import XCGLogger
import IQKeyboardManagerSwift

class GXMinePayManagerVC: GXBaseViewController {
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(separatorLeft: false)
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            tableView.sectionHeaderHeight = 12.0
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.register(cellType: GXMinePayManagerCell.self)
            tableView.register(cellType: GXMinePayBalanceCell.self)
            tableView.register(cellType: GXMinePayAddCell.self)
        }
    }
    
    private lazy var viewModel: GXMinePayManagerViewModel = {
        return GXMinePayManagerViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestStripePaymentList()
    }

    override func setupViewController() {
        self.navigationItem.title = "Payment Management"
        self.gx_addNavTopView(color: .white)
        self.gx_addBackBarButtonItem()
        self.confirmButton.setBackgroundColor(.gx_green, for: .normal)
        self.confirmButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
    }
    
    func updateDataSource() {
        guard let model = self.viewModel.model else { return }
        if self.viewModel.balanceData?.paymentMethod == "SETUP_INTENT" {
            for item in model.data {
                if item.default {
                    self.viewModel.selectedItem = item; break
                }
            }
        }
        self.tableView.reloadData()
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any?) {
        self.requestStripePaymentMethodSet()
    }
}

private extension GXMinePayManagerVC {
    func requestStripePaymentList() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestWalletConsumerBalance()
        }.then { model in
            self.viewModel.requestStripePaymentList()
        }.done { model in
            MBProgressHUD.dismiss()
            self.updateDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestStripePaymentDetach(index: Int) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestStripePaymentDetach(index: index)
        }.done { model in
            MBProgressHUD.dismiss()
            self.requestStripePaymentList()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestStripeConsumerSetupIntent() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestStripeConsumerSetupIntent()
        }.ensure {
            MBProgressHUD.dismiss()
        }.then { payModel in
            GXStripePaymentManager.paymentSheetToSetUp(data: payModel, fromVC: self)
        }.done { result in
            switch result {
            case .canceled: break
            case .completed:
                self.requestStripePaymentList()
            case .failed(let error):
                XCGLogger.info("Stripe payment error: \(error.localizedDescription)")
            }
        }.catch { error in
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestStripePaymentMethodSet() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestStripePaymentMethodSet()
        }.done { model in
            MBProgressHUD.dismiss()
            self.backBarButtonItemTapped()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
}

extension GXMinePayManagerVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let data = self.viewModel.model?.data else { return 0 }
        return data.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let count = self.viewModel.model?.data.count ?? 0
        if indexPath.section < count {
            let cell: GXMinePayManagerCell = tableView.dequeueReusableCell(for: indexPath)
            let model = self.viewModel.model?.data[indexPath.section]
            cell.bindCell(model: model)
            cell.checkButton.isSelected = self.viewModel.selectedItem == model
            cell.removeAction = {[weak self] in
                guard let `self` = self else { return }
                self.requestStripePaymentDetach(index: indexPath.section)
            }
            return cell
        }
        else if indexPath.section == count {
            let cell: GXMinePayBalanceCell = tableView.dequeueReusableCell(for: indexPath)
            cell.checkButton.isSelected = self.viewModel.selectedItem == nil
            return cell
        }
        else {
            let cell: GXMinePayAddCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = self.viewModel.model?.data.count ?? 0
        if indexPath.section < count {
            return 80
        }
        else {
            return 54
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        GXBaseTableView.setTableView(tableView, cell: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let count = self.viewModel.model?.data.count ?? 0
        if indexPath.section < count {
            self.viewModel.selectedItem = self.viewModel.model?.data[indexPath.section]
            self.tableView.reloadData()
        }
        else if indexPath.section == count {
            self.viewModel.selectedItem = nil
            self.tableView.reloadData()
        }
        else {
            self.requestStripeConsumerSetupIntent()
        }
    }
    
}
