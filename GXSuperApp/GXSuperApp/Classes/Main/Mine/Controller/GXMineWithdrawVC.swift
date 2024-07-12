//
//  GXMineWithdrawVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import PromiseKit
import MBProgressHUD

class GXMineWithdrawVC: GXBaseViewController {
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var textField: UITextField!

    private lazy var viewModel: GXMineWithdrawViewModel = {
        return GXMineWithdrawViewModel()
    }()
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.setRoundedCorners([.topLeft, .topRight], radius: 8.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestWalletConsumerBalance()
    }
    
    override func setupViewController() {
        self.gx_addBackBarButtonItem()
        
        let colors: [UIColor] = [.gx_green, .white]
        let gradientImage = UIImage(gradientColors: colors, style: .vertical, size: CGSize(width: 20, height: 10))
        self.topImageView.image = gradientImage

        self.confirmButton.setBackgroundColor(.gx_green, for: .normal)
        self.confirmButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
        self.textField.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.textField.markedTextRange == nil else { return }
            guard let balance = self.viewModel.balanceData?.available else { return }
            if string.count == 1 {
                if string == "." {
                    self.textField.text = nil
                }
            }
            var text = string
            var strArr = string.components(separatedBy: ".")
            if strArr.count == 2 {
                if strArr[1].count > 2 {
                    strArr[1] = strArr[1].substring(to: 2)
                    text = strArr.joined(separator: ".")
                    self.textField.text = text
                }
            }
            guard var unitPrice = Float(text) else { return }
            if unitPrice > balance {
                unitPrice = balance
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumFractionDigits = 2
                let stringValue = numberFormatter.string(from: NSNumber(value: unitPrice))
                self.textField.text = stringValue
            }
        }).disposed(by: disposeBag)
    }

}

private extension GXMineWithdrawVC {
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

private extension GXMineWithdrawVC {
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.backBarButtonItemTapped()
    }
    @IBAction func confirmButtonClicked(_ sender: UIButton) {

    }
    @IBAction func withdrawAllButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let balance = self.viewModel.balanceData?.available else { return }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        let stringValue = numberFormatter.string(from: NSNumber(value: balance))
        self.textField.text = stringValue
    }
}
