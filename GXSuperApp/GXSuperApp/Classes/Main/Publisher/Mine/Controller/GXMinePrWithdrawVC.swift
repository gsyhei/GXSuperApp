//
//  GXMinePrWithdrawVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/15.
//

import UIKit
import XCGLogger
import MBProgressHUD

class GXMinePrWithdrawVC: GXBaseViewController {
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var chargePriceLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textField: UITextField!

    private lazy var viewModel: GXMinePrWithdrawViewModel = {
        return GXMinePrWithdrawViewModel()
    }()
    
    class func createVC(data: GXGetMyWalletData) -> GXMinePrWithdrawVC {
        return GXMinePrWithdrawVC.xibViewController().then {
            $0.viewModel.walletData = data
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.didGetNetworktLoad {
            self.requestGetFinanceSetting()
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetFinanceSetting()
    }

    override func setupViewController() {
        self.title = "提现"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提现账号", style: .plain, target: self, action: #selector(rightBarButtonItemTapped))

        self.maxPriceLabel.text = String(format: "%.2f", self.viewModel.walletData.enableBalance)
        self.chargePriceLabel.text = nil
        self.submitButton.setBackgroundColor(.gx_green, for: .normal)
        self.submitButton.setBackgroundColor(.hex(hexString: "#C0FDD6"), for: .disabled)
        self.submitButton.isEnabled = false

        self.textField.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.textField.markedTextRange == nil else { return }
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
            if unitPrice > self.viewModel.walletData.enableBalance {
                unitPrice = self.viewModel.walletData.enableBalance
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumFractionDigits = 2
                let stringValue = numberFormatter.string(from: NSNumber(value: unitPrice))
                self.textField.text = stringValue
            }
            self.updatePrice(price: unitPrice)

        }).disposed(by: disposeBag)
    }

    func updatePrice(price: Float) {
        if price > 0 {
            self.submitButton.isEnabled = true
            if let data = self.viewModel.financeSettingData {
                var chargePrice = price * (data.withdrawalFeeRate/100)
                chargePrice = max(chargePrice, data.minWithdrawalFee)
                chargePrice = min(chargePrice, data.maxWithdrawalFee)
                self.chargePriceLabel.text = String(format: "申请手续费¥%.2f", chargePrice)
            }
        }
        else {
            self.submitButton.isEnabled = false
            self.chargePriceLabel.text = nil
        }
    }
}

extension GXMinePrWithdrawVC {
    func requestGetFinanceSetting() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetFinanceSetting(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view, animated: false)
        }, failure: {[weak self] error in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showError(error, to: self.view)
        })
    }
    func requestGetWithdrawAccount() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetWithdrawAccount(success: {[weak self] in
            guard let `self` = self else { return }
            self.updateWithdrawAccount()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    func requestCreateWithdraw() {
        self.viewModel.requestCreateWithdraw(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.showSuccessAlert()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    func showSuccessAlert() {
        let title = "提交成功\n平台会在1-2个工作日内审核\n请耐心等待！"
        GXUtil.showAlert(title: title, cancelTitle: "我知道了") { alert, index in
            self.navigationController?.popViewController(animated: true)
        }
    }
    func updateWithdrawAccount() {
        guard let data = self.viewModel.withdrawAccountData, data.alipayAccount.count > 0 else {
            MBProgressHUD.dismiss(for: self.view)
            if (GXUserManager.shared.user?.phone.count ?? 0) > 0 {
                let vc = GXMinePrWithdrawAccountVC.xibViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = GXLoginAllVC.xibViewController()
                vc.loginType = .bindPhone
                vc.completion = { formVC in
                    let vc = GXMinePrWithdrawAccountVC.xibViewController()
                    formVC?.navigationController?.pushViewController(vc, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        self.requestCreateWithdraw()
    }
}

extension GXMinePrWithdrawVC {
    @objc func rightBarButtonItemTapped() {
        self.view.endEditing(true)
        MBProgressHUD.dismiss(for: self.view)
        if (GXUserManager.shared.user?.phone.count ?? 0) > 0 {
            let vc = GXMinePrWithdrawAccountVC.xibViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = GXLoginAllVC.xibViewController()
            vc.loginType = .bindPhone
            vc.completion = { formVC in
                let vc = GXMinePrWithdrawAccountVC.xibViewController()
                formVC?.navigationController?.pushViewController(vc, animated: true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func allButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        let price = self.viewModel.walletData.enableBalance
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        let stringValue = numberFormatter.string(from: NSNumber(value: price))
        self.textField.text = stringValue
        self.updatePrice(price: price)
    }
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let price = Float(textField.text ?? ""), price > 0 else { return }
        self.viewModel.withdrawPrice = price
        self.requestGetWithdrawAccount()
    }
}

