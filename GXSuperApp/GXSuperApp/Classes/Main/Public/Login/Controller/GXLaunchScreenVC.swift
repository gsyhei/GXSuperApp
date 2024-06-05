//
//  GXLaunchScreenVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/26.
//

import UIKit
import MBProgressHUD

class GXLaunchScreenVC: GXBaseViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.requestCheckVersion()
    }

    /// 检查版本更新
    func requestCheckVersion() {
        MBProgressHUD.showLoading(ballColor: .white, to: self.view)
        var params: Dictionary<String, Any> = [:]
        params["appType"] = 2 //app类型 1-android 2-ios
        params["versionNo"] = UIApplication.appVersion()
        let api = GXApi.normalApi(Api_About_CheckVersion, params, .get)
        GXNWProvider.gx_request(api, type: GXCheckVersionModel.self, success: {[weak self] model in
            MBProgressHUD.dismiss(for: self?.view)
            self?.checkVersion(model: model.data)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            self?.checkVersion(model: nil)
        })
    }
    
    func checkVersion(model: GXCheckVersionData?) {
        guard let model = model else {
            GXAppDelegate?.changeRoleType()
            return
        }
        if model.hasNewVersion {
            self.showAlertUpdate(model: model)
        }
        else {
            GXAppDelegate?.changeRoleType()
        }
    }

    func showAlertUpdate(model: GXCheckVersionData) {
        let alert = GXAlertView(frame: .zero)
        var actions: [GXAlertAction] = []

        let updateAction = GXAlertAction()
        updateAction.title = "去更新"
        updateAction.titleFont = .gx_boldFont(size: 17)
        updateAction.titleColor = .gx_drakGreen
        updateAction.action = { alertView in
            let urlString = "itms-apps://itunes.apple.com/app/apple-store/id1589720335?mt=8"
            if let appleStoreUrl = URL(string: urlString) {
                UIApplication.shared.open(appleStoreUrl, completionHandler: nil)
            }
        }
        actions.append(updateAction)
        if !model.forceUpdate {
            let cancelAction = GXAlertAction()
            cancelAction.title = "取消"
            cancelAction.titleFont = .gx_boldFont(size: 17)
            cancelAction.titleColor = .gx_drakGreen
            cancelAction.action = { alertView in
                GXAppDelegate?.changeRoleType()
            }
            actions.append(cancelAction)
        }
        alert.createAlert(title: "发现新版本", message: model.versionContent, actions: actions)
        alert.show(to: view, style: .alert, backgoundTapDismissEnable: false, usingSpring: true)
    }
}
