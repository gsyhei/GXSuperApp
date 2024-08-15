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
        self.gx_addBackBarButtonItem()
        self.confirmButton.setBackgroundColor(.gx_green, for: .normal)
        self.confirmButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
    }
    
    func updateDataSource() {
        guard (self.viewModel.model != nil) else { return }
        self.tableView.reloadData()
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any?) {
        self.requestStripePaymentMethodSet()
    }
}

private extension GXMinePayManagerVC {
    func requestStripePaymentList() {
        MBProgressHUD.showLoading()
        let combinedPromise = when(fulfilled: [
            self.viewModel.requestStripePaymentList(),
            self.viewModel.requestWalletConsumerBalance()
        ])
        firstly {
            combinedPromise
        }.done { model in
            MBProgressHUD.dismiss()
            self.updateDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestStripePaymentDetach() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestStripePaymentDetach()
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
        guard let paymentMethod = self.viewModel.paymentMethod,
              paymentMethod != self.viewModel.balanceData?.paymentMethod
        else {
            self.backBarButtonItemTapped()
            return
        }
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
        if (self.viewModel.model != nil) {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: GXMinePayManagerCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bindCell(model: self.viewModel.model?.data.first)
            cell.checkButton.isSelected = (self.viewModel.paymentMethod == "SETUP_INTENT")
            cell.removeAction = {[weak self] isRemove in
                guard let `self` = self else { return }
                if isRemove {
                    self.requestStripePaymentDetach()
                } else {
                    self.requestStripeConsumerSetupIntent()
                }
            }
            return cell
        case 1:
            let cell: GXMinePayBalanceCell = tableView.dequeueReusableCell(for: indexPath)
            cell.checkButton.isSelected = (self.viewModel.paymentMethod == "BALANCE")
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
        case 0: 
            self.viewModel.paymentMethod = "SETUP_INTENT"
        case 1:
            self.viewModel.paymentMethod = "BALANCE"
        default: break
        }
        self.tableView.reloadData()
    }
    
}
