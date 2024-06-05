//
//  GXMinePtVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/28.
//

import UIKit
import GXConfigTableViewVC
import MBProgressHUD
import Popover

class GXMinePtVC: GXConfigTableViewController {

    private lazy var headerView: GXMinePtHeaderView = {
        return GXMinePtHeaderView.xibView().then {
            $0.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 306)
            $0.backgroundColor = .red
        }
    }()

    private lazy var viewModel: GXMinePtViewModel = {
        return GXMinePtViewModel().then {
            $0.viewController = self
        }
    }()

    private lazy var popover: Popover = {
        let color = UIColor(white: 0, alpha: 0.1)
        let size = CGSize(width: 16.0, height: 8.0)
        let options:[PopoverOption] = [.type(.up),.sideEdge(5.0),.blackOverlayColor(color),
                                       .color(.gx_black), .arrowSize(size),.animationIn(0.3)]
        return Popover(options: options)
    }()
    private var isShowPopover: Bool {
        get {
            return UserDefaults.standard.bool(forKey: GX_PTSHOW_POPOVER_KEY)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: GX_PTSHOW_POPOVER_KEY)
            UserDefaults.standard.synchronize()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestGetUserInfo(isShowHud: GXUserManager.shared.user == nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self.viewModel.dataSource
        self.tableView?.contentInsetAdjustmentBehavior = .never
        self.tableView?.tableHeaderView = self.headerView
        if let user = GXUserManager.shared.user {
            self.headerView.bindModel(model: user, superVC: self)
        }
        self.tableView?.configuration()
        self.tableView?.separatorColor = .gx_lightGray
        self.tableView?.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
    }
    
    func requestGetUserInfo(isShowHud: Bool = true) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetUserInfo(success: {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            if let user = GXUserManager.shared.user {
                self?.headerView.bindModel(model: user, superVC: self)
                self?.showPublishPopover()
            }
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func showPublishPopover() {
        if !self.isShowPopover {
            self.isShowPopover = true
            let right = self.view.width - 50
            let bottom = self.headerView.height + 270
            let point = CGPoint(x: right, y: bottom)
            let view = GXMineChangeRoleView.createView()
            self.popover.show(view, point: point)
        }
    }
}
