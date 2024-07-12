//
//  GXMineWalletVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import PromiseKit
import MBProgressHUD

class GXMineWalletVC: GXBaseViewController {
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var rechargeButton: UIButton!
    
    private lazy var viewModel: GXMineWalletViewModel = {
        return GXMineWalletViewModel()
    }()
    
    class func createVC(balanceData: GXWalletConsumerBalanceData?) -> GXMineWalletVC {
        return GXMineWalletVC.xibViewController().then {
            $0.hidesBottomBarWhenPushed = true
            $0.viewModel.balanceData = balanceData
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.detailButton.imageLocationAdjust(model: .right, spacing: 5.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestWalletConsumerBalance()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "My Wallet"
        self.gx_addBackBarButtonItem()
        
        let colors: [UIColor] = [.gx_green, .gx_blue]
        let gradientImage = UIImage(gradientColors: colors, style: .obliqueDown, size: CGSize(width: 20, height: 10))
        self.topImageView.image = gradientImage

        self.withdrawButton.layer.borderWidth = 1.0
        self.withdrawButton.layer.borderColor = UIColor.gx_green.cgColor
        self.withdrawButton.setBackgroundColor(.white, for: .normal)
        self.withdrawButton.setBackgroundColor(.gx_background, for: .highlighted)
        
        self.rechargeButton.setBackgroundColor(.gx_green, for: .normal)
        self.rechargeButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
        self.updateDataSource()
    }
}

private extension GXMineWalletVC {
    func requestWalletConsumerBalance() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestWalletConsumerBalance()
        }.done { models in
            MBProgressHUD.dismiss()
            self.updateDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func updateDataSource() {
        self.balanceLabel.text = String(format: "$ %.2f", self.viewModel.balanceData?.available ?? 0)
    }
}

private extension GXMineWalletVC {
    @IBAction func detailButtonClicked(_ sender: UIButton) {
        let vc = GXMineStatementVC.createVC(viewModel: self.viewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func withdrawButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func rechargeButtonClicked(_ sender: UIButton) {

    }
}
