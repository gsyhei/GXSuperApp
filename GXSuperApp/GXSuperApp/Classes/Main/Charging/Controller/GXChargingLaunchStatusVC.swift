//
//  GXChargingLaunchStatusVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/6.
//

import UIKit
import MBProgressHUD
import PromiseKit

class GXChargingLaunchStatusVC: GXBaseViewController {
    @IBOutlet weak var failedView: UIView!
    weak var viewModel: GXChargingFeeConfirmViewModel!
    
    class func createVC(viewModel: GXChargingFeeConfirmViewModel) -> GXChargingLaunchStatusVC {
        return GXChargingLaunchStatusVC.xibViewController().then {
            $0.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestOrderConsumerStart()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Launch Failed"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
        
        self.failedView.isHidden = true
    }
    
    func requestOrderConsumerStart() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestOrderConsumerStart()
        }.done { model in
            MBProgressHUD.dismiss()
            /// 启动成功-> 状态充电中
            if let orderId = model.data?.id {
                let vc = GXChargingCarShowVC.createVC(orderId: orderId)
                self.navigationController?.pushByReturnToViewController(vc: vc, animated: true)
            }
        }.catch { error in
            self.failedView.isHidden = false
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
}

extension GXChargingLaunchStatusVC {
    @IBAction func scanButtonClicked(_ sender: Any?) {
        let vc = GXQRCodeReaderVC.xibViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.didFindCodeAction = {[weak self] (model, scanVC) in
            guard let `self` = self else { return }
            let vc = GXChargingFeeConfirmVC.instantiate()
            vc.viewModel.scanData = model.data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.navigationController?.present(vc, animated: true)
        self.navigationController?.popToRootViewController(animated: false)
    }
}
