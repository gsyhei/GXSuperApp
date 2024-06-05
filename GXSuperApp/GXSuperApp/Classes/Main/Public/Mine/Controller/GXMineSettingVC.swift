//
//  GXMineSettingVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import GXConfigTableViewVC
import Kingfisher
import MBProgressHUD

class GXMineSettingVC: GXConfigTVC {
    @IBOutlet weak var quitButton: UIButton!
    
    private lazy var navTopView: UIView = {
        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: SCREEN_HEIGHT, height: 44))).then {
            $0.backgroundColor = .white
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        self.view.backgroundColor = .gx_background
        self.gx_addBackBarButtonItem()
        
        self.quitButton.setTitleColor(.gx_red, for: .normal)
        self.quitButton.setBackgroundColor(.white, for: .normal)
        self.tableView?.separatorColor = .gx_lightGray
        self.tableView?.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.tableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 16))

        let model = GXConfigTableModel()
        model.style = .insetGrouped
        model.backgroundColor = .gx_background
        let separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        let row0 = GXConfigTableRowDefaultModel()
        row0.separatorInset = separatorInset
        row0.rowHeight = 48.0
        row0.contentMargin = 12.0
        row0.title.accept("清缓存")
        row0.titleFont = .gx_font(size: 17)
        row0.titleColor = .gx_black
        row0.action = {
            MBProgressHUD.showLoading()
            KingfisherManager.shared.cache.clearDiskCache {
                MBProgressHUD.dismiss()
                GXToast.showSuccess(text: "已清空")
            }
        }
        let row1 = GXConfigTableRowDefaultModel()
        row1.separatorInset = separatorInset
        row1.rowHeight = 48.0
        row1.contentMargin = 12.0
        row1.title.accept("消息通知")
        row1.titleFont = .gx_font(size: 17)
        row1.titleColor = .gx_black
        row1.action = {[weak self] in
            let vc = GXMineSettingNotifiVC()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        let row2 = GXConfigTableRowDefaultModel()
        row2.separatorInset = separatorInset
        row2.rowHeight = 48.0
        row2.contentMargin = 12.0
        row2.title.accept("注销账号")
        row2.titleFont = .gx_font(size: 17)
        row2.titleColor = .gx_black
        row2.action = {[weak self] in
            let title = "确定注销吗？\n注销后数据将永久丢失"
            GXUtil.showAlert(title: title, actionTitle: "确定") { alert, index in
                guard index == 1 else { return }
                self?.requestCancelAccount()
            }
        }
        let section0 = GXConfigTableSectionModel()
        section0.rowList = [row0, row1, row2]
        model.sectionList = [section0]
        self.dataSource = model
    }
}

extension GXMineSettingVC {
    func requestLogout() {
        MBProgressHUD.showLoading(to: self.view)
        let api = GXApi.normalApi(Api_User_Logout, [:], .post)
        GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXUserManager.logout()
            GXAppDelegate?.changeRoleType()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    func requestCancelAccount() {
        MBProgressHUD.showLoading(to: self.view)
        let api = GXApi.normalApi(Api_User_CancelAccount, [:], .post)
        GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXUserManager.logout()
            GXAppDelegate?.changeRoleType()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    
    @IBAction func quitButtonClicked(_ sender: UIButton) {
        GXUtil.showAlert(title: "确定退出登录吗？", actionTitle: "确定") { alert, index in
            guard index == 1 else { return }
            self.requestLogout()
        }
    }
}
