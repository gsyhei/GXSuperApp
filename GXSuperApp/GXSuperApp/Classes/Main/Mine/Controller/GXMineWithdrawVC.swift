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
                if string == "." || balance == 0 {
                    self.textField.text = nil
                    return
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
            guard let price = Float(text) else { return }
            if price > balance {
                self.textField.text = String(format: "%.2f", balance)
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
    func requestWithdrawConsumerSubmit(amount: Float) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestWithdrawConsumerSubmit(amount: amount)
        }.done { model in
            MBProgressHUD.dismiss()
            self.showAlertSubmitted(mutable: model.data.count > 1)
        }.catch { error in
            MBProgressHUD.dismiss()
            self.showAlertError(errText: error.localizedDescription)
        }
    }
    func showAlertError(errText: String) {
        let message = "Unable to withdraw"
        GXUtil.showAlert(title: errText, message: message, cancelTitle: "I see", handler: { alert, index in
            self.navigationController?.popViewController(animated: true)
        })
    }
    func showAlertSubmitted(mutable: Bool) {
        let title = "The withdrawal application has been submitted"
        var message = "The money will be transferred according to the original channel at the time of recharge."
        if mutable {
            message += "\nWhen you recharge, you will pay through multiple channels. When you withdraw, you will call different channels. Please note that check."
        }
        GXUtil.showAlert(title: title, message: message, cancelTitle: "I see", handler: { alert, index in
            self.navigationController?.popViewController(animated: true)
        })
    }
}

private extension GXMineWithdrawVC {
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.backBarButtonItemTapped()
    }
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        guard let amount = Float(self.textField.text ?? "") else { return }
        self.requestWithdrawConsumerSubmit(amount: amount)
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
