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
import PromiseKit
import XCGLogger

class GXLaunchScreenVC: GXBaseViewController {
    private let networkManager = NetworkReachabilityManager(host: "www.google.com")

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        MBProgressHUD.showLoading(style: .waveBall, ballColor: .black, to: self.view)
        self.networkManager?.startListening {[weak self] status in
            guard let `self` = self else { return }
            guard status != .notReachable else { return }
            self.requestCheckVersion()
            self.restoreCompletedTransactions()
        }
    }
    
    func restoreCompletedTransactions() {
        guard GXUserManager.shared.isLogin else { return }
        
        firstly {
            GXNWProvider.login_requestUserInfo()
        }.then { model in
            SKPaymentQueue.default().restoreCompletedTransactions(.promise, withApplicationUsername: model.data?.uuid)
        }.done { transactions in
            if let transaction = transactions.first(where: { $0.payment.productIdentifier == GX_PRODUCT_ID }) {
                self.requestAppleVerifyReceipt(transaction: transaction)
            }
        }.catch { error in
            XCGLogger.info("SKPaymentQueue error: \(error)")
        }
    }
    
    func requestAppleVerifyReceipt(transaction: SKPaymentTransaction) {
//        GXNWProvider.login_requestAppleVerifyReceipt(transaction: transaction).done { model in
//            GXUserManager.shared.user?.memberFlag = .YES
//            XCGLogger.info("AppleVerifyReceipt transaction: \(transaction)")
//        }.catch { error in
//            XCGLogger.info("AppleVerifyReceipt error: \(error)")
//        }
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
            GXAppDelegate?.gotoMainTabbarController()
            return
        }
        GXUserManager.shared.appUpdateData = data
        if data.version == UIApplication.appVersion() {
            GXAppDelegate?.gotoMainTabbarController()
        }
        else {
            self.showAlertUpdate(data: data)
        }
    }
    
    func showAlertUpdate(data: GXAppUpdateLatestData) {
        if data.forceFlag == GX_YES {
            let title = "The app has an updated version."
            GXUtil.showAlert(title: title, cancelTitle: "Update now", actionHandler: { alert, index in
                let urlString = "itms-apps://itunes.apple.com/app/apple-store/id6618148723?mt=8"
                if let appleStoreUrl = URL(string: urlString) {
                    UIApplication.shared.open(appleStoreUrl, completionHandler: nil)
                }
            })
        }
        else {
            let title = "The app has an updated version."
            GXUtil.showAlert(title: title, cancelTitle: "Cancel", actionTitle: "Update now", actionHandler: { alert, index in
                if index == 0 {
                    GXAppDelegate?.gotoMainTabbarController()
                }
                else {
                    let urlString = "itms-apps://itunes.apple.com/app/apple-store/id6618148723?mt=8"
                    if let appleStoreUrl = URL(string: urlString) {
                        UIApplication.shared.open(appleStoreUrl, completionHandler: nil)
                    }
                }
            })
        }
    }
    
}
