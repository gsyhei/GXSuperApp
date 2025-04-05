//
//  GXVipVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/13.
//

import UIKit
import Kingfisher
import MBProgressHUD
import PromiseKit
import XCGLogger

class GXVipVC: GXBaseViewController {
    @IBOutlet weak var backgroudImageView: UIImageView!
    @IBOutlet weak var vipImageView: UIImageView!
    @IBOutlet weak var vipImageHeightLC: NSLayoutConstraint!
    
    private lazy var viewModel: GXVipViewModel = {
        return GXVipViewModel().then {
            $0.autouUpdateVipAction = {[weak self] isVip in
                MBProgressHUD.dismiss()
                self?.updateDataSource()
            }
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestParamConsumer()
    }
    
    override func setupViewController() {
        let bgColors: [UIColor] = [UIColor(hexString: "#FFE7C3"), .white]
        let backImage = UIImage(gradientColors: bgColors, style: .vertical)
        self.backgroudImageView.image = backImage
        
        self.updateDataSource()
    }
    
    func updateDataSource() {
        if let params = GXUserManager.shared.paramsData {
            // params.memberDescription
            self.vipImageView.kf.setImage(with: URL(string: params.memberDescription)) { result in
                switch result {
                case .success(let image):
                    self.vipImageHeightLC.constant = self.getImageViewHeight(image: image.image)
                    self.view.layoutIfNeeded()
                case .failure(_): break
                }
            }
        }
    }
    
}

private extension GXVipVC {
    
    func requestParamConsumer() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestParamConsumer()
        }.done { models in
            MBProgressHUD.dismiss()
            self.updateDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func getImageViewHeight(image: UIImage) -> CGFloat {
        let scale = image.size.height / image.size.width
        return (SCREEN_WIDTH - 24) * scale
    }
    
}

extension GXVipVC: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.didLinkScheme(URL.absoluteString)
        return false
    }
    
    func didLinkScheme(_ scheme: String) {
        switch scheme {
        case "yhxy":
            let vc = GXWebViewController(urlString: GXUtil.gx_h5Url(id: 8),
                                         title: "Membership Service Agreement")
            self.navigationController?.pushViewController(vc, animated: true)
        case "yszc":
            let vc = GXWebViewController(urlString: GXUtil.gx_h5Url(id: 12),
                                         title: "Automatic Renewal Terms")
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}

private extension GXVipVC {
    @IBAction func checkButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
//        self.confirmButton.isEnabled = sender.isSelected
//        self.renewButton.isEnabled = sender.isSelected
    }
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        guard SKPaymentQueue.canMakePayments() else {
            GXToast.showError(text: "The device cannot or does not allow payment.")
            return
        }
        self.viewModel.autouUpdateVipAction = { isVip in
            MBProgressHUD.dismiss(for: self.view)
            GXAppDelegate?.gotoMainTabbarController(index: 1)
        }
        MBProgressHUD.showLoading(to: self.view)
        firstly {
            SKProductsRequest(productIdentifiers: [GX_PRODUCT_ID]).start(.promise)
        }.then { response in
            SKPayment.gx_paymentPromise(response: response)
        }.done { transaction in
            self.validateReceipt(transaction: transaction)
        }.catch { error in
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func validateReceipt(transaction: SKPaymentTransaction) {
        MBProgressHUD.dismiss(for: self.view)
        
        SKPayment.validateReceipt(completion: { model in
            guard let model = model else { return }
//            let systemTimeInterval = GXServiceManager.shared.systemDate.timeIntervalSince1970 * 1000
//            guard model.expires_date_ms > systemTimeInterval else { return }
            
            if model.app_account_token != GXUserManager.shared.user?.uuid {
                GXUtil.showAlert(title: "Alert", message: "You have subscribed to VIP on another MarsEnergy account!", cancelTitle: "I see")
            }
            else {
                MBProgressHUD.showLoading(to: self.view)
                self.viewModel.autoUpdateVipRequest()
            }
        })
    }
}
