//
//  GXLaunchScreenVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/26.
//

import UIKit
import MBProgressHUD
import Alamofire
import CoreTelephony

class GXLaunchScreenVC: GXBaseViewController {
    private let networkManager = NetworkReachabilityManager(host: "www.google.com")
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        MBProgressHUD.showLoading(style: .waveBall, ballColor: .white, to: self.view)
        self.networkManager?.startListening {[weak self] status in
            guard let `self` = self else { return }
            guard status != .notReachable else { return }
            self.requestCheckVersion()
        }
    }
    
    func gotoMainTabbarController() {
        let vc = GXTabBarController()
        GXAppDelegate?.setWindowRootViewController(to: vc)
    }
    
    /// 检查版本更新
    func requestCheckVersion() {
        self.networkManager?.stopListening()
        var params: Dictionary<String, Any> = [:]
        params["appType"] = "IOS"
        let api = GXApi.normalApi(Api_app_update_latest, params, .get)
        GXNWProvider.gx_request(api, type: GXAppUpdateLatestModel.self, success: {[weak self] model in
            self?.checkVersion(data: model.data)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            self?.checkVersion(data: nil)
        })
    }
    
    func checkVersion(data: GXAppUpdateLatestData?) {
        MBProgressHUD.dismiss(for: self.view)

        guard let data = data else {
            self.gotoMainTabbarController()
            return
        }
        GXUserManager.shared.appUpdateLatestData = data
        if data.version == UIApplication.appVersion() {
            self.gotoMainTabbarController()
        }
        else {
            self.showAlertUpdate(data: data)
        }
    }
    
    func showAlertUpdate(data: GXAppUpdateLatestData) {
        if data.forceFlag == GX_YES {
            let title = "The app has an updated version."
            GXUtil.showAlert(title: title, cancelTitle: "Update now", actionHandler: { alert, index in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, completionHandler: nil)
                }
            })
        }
        else {
            let title = "The app has an updated version."
            GXUtil.showAlert(title: title, cancelTitle: "Cancel", actionTitle: "Update now", actionHandler: { alert, index in
                if index == 0 {
                    self.gotoMainTabbarController()
                }
                else {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings, completionHandler: nil)
                    }
                }
            })
        }
    }
    
}
