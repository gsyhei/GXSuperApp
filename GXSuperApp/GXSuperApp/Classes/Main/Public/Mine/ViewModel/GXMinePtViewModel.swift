//
//  GXMinePtViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/28.
//

import UIKit
import GXConfigTableViewVC

class GXMinePtViewModel: GXBaseViewModel {
    weak var viewController: UIViewController?

    lazy var dataSource: GXConfigTableModel = {
        let model = GXConfigTableModel()
        model.style = .plain
        model.backgroundColor = .white

        let section0 = GXConfigTableSectionModel()

        let row0 = GXConfigTableRowDefaultModel()
        row0.rowHeight = 52.0
        row0.contentMargin = 16.0
        row0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row0.title.accept("我的订单")
        row0.image.accept(UIImage(named: "m_order_icon"))
        row0.titleFont = .gx_boldFont(size: 16)
        row0.action = {[weak self] in
            if GXUserManager.shared.roleType == .publisher {
                let vc = GXMinePrOrderVC.xibViewController()
                vc.hidesBottomBarWhenPushed = true
                self?.viewController?.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = GXMinePtOrderVC()
                vc.hidesBottomBarWhenPushed = true
                self?.viewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        let row1 = GXConfigTableRowDefaultModel()
        row1.rowHeight = 52.0
        row1.contentMargin = 16.0
        row1.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row1.title.accept("实名认证")
        row1.image.accept(UIImage(named: "m_real_icon"))
        row1.titleFont = .gx_boldFont(size: 16)
        row1.action = {[weak self] in
            let vc = GXMinePtRealNameVC.xibViewController().then {
                $0.realnameFlag = GXUserManager.shared.user?.realnameFlag ?? 0
                $0.hidesBottomBarWhenPushed = true
            }
            self?.viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        let row2 = GXConfigTableRowDefaultModel()
        row2.rowHeight = 52.0
        row2.contentMargin = 16.0
        row2.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row2.title.accept("我的地址")
        row2.image.accept(UIImage(named: "m_location_icon"))
        row2.titleFont = .gx_boldFont(size: 16)
        row2.action = {[weak self] in
            let vc = GXMinePtAddressesVC.xibViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        let row22 = GXConfigTableRowDefaultModel()
        row22.rowHeight = 52.0
        row22.contentMargin = 16.0
        row22.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row22.title.accept("机构认证")
        row22.image.accept(UIImage(named: "m_real_icon"))
        row22.titleFont = .gx_boldFont(size: 16)
        row22.action = {[weak self] in
            let vc = GXMinePrAccreditationVC.xibViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        let row23 = GXConfigTableRowDefaultModel()
        row23.rowHeight = 52.0
        row23.contentMargin = 16.0
        row23.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row23.title.accept("我的钱包")
        row23.image.accept(UIImage(named: "m_purse_icon"))
        row23.titleFont = .gx_boldFont(size: 16)
        row23.action = {[weak self] in
            let vc = GXMinePrWalletVC.xibViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        let row3 = GXConfigTableRowDefaultModel()
        row3.rowHeight = 52.0
        row3.contentMargin = 16.0
        row3.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row3.title.accept("关于我们")
        row3.image.accept(UIImage(named: "m_about_icon"))
        row3.titleFont = .gx_boldFont(size: 16)
        row3.action = {[weak self] in
            let vc = GXWebViewController(urlString: Api_WebBaseUrl + "/h5/#/aboutus", title: "关于我们")
            vc.hidesBottomBarWhenPushed = true
            self?.viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        let row4 = GXConfigTableRowDefaultModel()
        row4.rowHeight = 52.0
        row4.contentMargin = 16.0
        row4.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row4.title.accept("我要反馈")
        row4.image.accept(UIImage(named: "m_feedback_icon"))
        row4.titleFont = .gx_boldFont(size: 16)
        row4.action = {[weak self] in
            let vc = GXMineFeedbackVC.xibViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        let row5 = GXConfigTableRowDefaultModel()
        row5.rowHeight = 52.0
        row5.contentMargin = 16.0
        row5.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row5.title.accept("角色切换")
        if GXUserManager.shared.roleType == .publisher {
            row5.detail.accept("切换为用户")
        } else {
            row5.detail.accept("切换为活动发布者")
        }
        row5.image.accept(UIImage(named: "m_change_icon"))
        row5.titleFont = .gx_boldFont(size: 16)
        row5.detailFont = .gx_boldFont(size: 16)
        row5.action = {
            self.showAlert()
        }
        let row6 = GXConfigTableRowDefaultModel()
        row6.rowHeight = 52.0
        row6.contentMargin = 16.0
        row6.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row6.title.accept("设置")
        row6.image.accept(UIImage(named: "m_setting_icon"))
        row6.titleFont = .gx_boldFont(size: 16)
        row6.action = {[weak self] in
            let vc = GXMineSettingVC.xibViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.viewController?.navigationController?.pushViewController(vc, animated: true)
        }

        if GXUserManager.shared.roleType == .publisher {
            section0.rowList = [row0, row1, row22, row23, row3, row4, row5, row6]
        } else {
            section0.rowList = [row0, row1, row2, row3, row4, row5, row6]
        }
        model.sectionList = [section0]

        return model
    }()

    func showAlert() {
        var title: String = ""
        if GXUserManager.shared.roleType == .publisher {
            title = "确定切换为用户吗？"
        } else {
            title = "确定切换为活动发布者吗？"
        }
        GXUtil.showAlert(title: title, actionTitle: "确定") { alert, index in
            guard index == 1 else { return }

            if GXUserManager.shared.roleType == .publisher {
                GXUserManager.updateRoleType(.participant)
            } else {
                GXUserManager.updateRoleType(.publisher)
            }
            GXAppDelegate?.changeRoleType(index: 0)
        }
    }

    /// 获取个人信息
    func requestGetUserInfo(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let api = GXApi.normalApi(Api_User_GetUserInfo, [:], .get)
        let cancellable = GXNWProvider.gx_request(api, type: GXUserInfoModel.self, success: { model in
            if let userInfo = model.data {
                GXUserManager.updateUser(userInfo)
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
