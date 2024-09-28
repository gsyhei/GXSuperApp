//
//  GXMineAccountManagerVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import PromiseKit
import MBProgressHUD

class GXMineAccountManagerVC: GXBaseViewController {
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.configuration(separatorLeft: false)
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            tableView.sectionHeaderHeight = 12.0
            tableView.sectionFooterHeight = .leastNormalMagnitude
            tableView.register(cellType: GXMineDefaultCell.self)
            tableView.isScrollEnabled = false
        }
    }
    
    private lazy var viewModel: GXMineAccountManagerViewModel = {
        return GXMineAccountManagerViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Account Management"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
        
        self.logoutButton.setBackgroundColor(.gx_red, for: .normal)
        self.logoutButton.setBackgroundColor(.gx_drakRed, for: .highlighted)
        
        if let model = GXUserManager.shared.user {
            if model.phoneNumber.count > 6 {
                let starCount = model.phoneNumber.count - 5
                let beginText = model.phoneNumber.substring(to: 3)
                let endText = model.phoneNumber.substring(from: starCount + 3)
                var phoneText = "+" + model.nationCode + " " + beginText
                for _ in 0..<starCount {
                    phoneText += "*"
                }
                phoneText += endText
                self.phoneLabel.text = phoneText
            }
            else {
                self.phoneLabel.text = "+" + model.nationCode + " " + "****"
            }
        }
        else {
            self.phoneLabel.text = "****"
        }
    }
    
}

private extension GXMineAccountManagerVC {
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        self.showUerLogoutAlert()
    }
}

private extension GXMineAccountManagerVC {
    func requestUserLogout() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestUserLogout()
        }.done { model in
            MBProgressHUD.dismiss()
            GXUserManager.logout()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestUserCancel() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestUserCancel()
        }.done { model in
            MBProgressHUD.dismiss()
            GXUserManager.logout()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func showUerLogoutAlert() {
        GXUtil.showAlert(title: "Log Out", message: "Are you sure you want to log out?", actionTitle: "OK", handler: { alert, index in
            guard index == 1 else { return }
            self.requestUserLogout()
        })
    }
    func showUserCancelAlert() {
        GXUtil.showAlert(title: "Deactivate account", message: "Are you sure to cancel the account? Data will be permanently lost after account cancellation!", actionTitle: "OK", handler: { alert, index in
            guard index == 1 else { return }
            self.requestUserCancel()
        })
    }
}

extension GXMineAccountManagerVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: GXMineDefaultCell = tableView.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = "Deactivate Account"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 54
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
            self.showUserCancelAlert()
        default: break
        }
    }
    
}
