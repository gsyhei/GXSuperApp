//
//  GXMinePrWithdrawAccountVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/15.
//

import UIKit
import XCGLogger
import RxCocoaPlus
import MBProgressHUD

class GXMinePrWithdrawAccountVC: GXBaseViewController {
    /// 支付宝账号
    @IBOutlet weak var aliAcccountTF: UITextField!
    /// 真实姓名
    @IBOutlet weak var realNameTF: UITextField!
    /// 验证码
    @IBOutlet weak var captchaTF: UITextField!
    /// 保存
    @IBOutlet weak var saveButton: UIButton!
    /// 发送验证码
    @IBOutlet weak var sendButton: UIButton!
    private var countdown: Int = 60 {
        didSet {
            self.sendButton.setTitle(String(format: "%ds", self.countdown), for: .disabled)
        }
    }

    private lazy var viewModel: GXMinePrWithdrawAccountViewModel = {
        return GXMinePrWithdrawAccountViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetWithdrawAccount()
    }

    override func setupViewController() {
        self.title = "提现支付宝账号"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.saveButton.setBackgroundColor(.gx_green, for: .normal)
        self.updateSendButton(isSend: false)
        
        (self.aliAcccountTF.rx.textInput <-> self.viewModel.aliAcccount).disposed(by: disposeBag)
        (self.realNameTF.rx.textInput <-> self.viewModel.realName).disposed(by: disposeBag)
        (self.captchaTF.rx.textInput <-> self.viewModel.captcha).disposed(by: disposeBag)
    }

    func updateWithdrawAccount() {
        guard let data = self.viewModel.withdrawAccountData else { return }
        self.viewModel.aliAcccount.accept(data.alipayAccount)
        self.viewModel.realName.accept(data.realName)
    }
}

extension GXMinePrWithdrawAccountVC {

    func requestGetWithdrawAccount() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetWithdrawAccount(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.updateWithdrawAccount()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestGetSmsCode() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetSmsCode(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "验证码已发送")
            self.startKeepTime()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }

    func requestSetWithdrawAccount() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSetWithdrawAccount(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            GXToast.showSuccess(text: "保存成功")
            self.navigationController?.popToViewController(vcType: GXMinePrWithdrawVC.self, animated: true)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
}

extension GXMinePrWithdrawAccountVC {
    func updateSendButton(isSend: Bool) {
        if isSend {
            self.sendButton.gx_setDisabledButton()
        } else {
            self.sendButton.gx_setGreenBorderButton()
            self.sendButton.setTitle("发送验证码", for: .normal)
        }
    }
    func startKeepTime() {
        self.updateSendButton(isSend: true)
        GXUtil.gx_countdownTimer(second: 60) {[weak self] (index) in
            guard let `self` = self else { return }
            self.countdown = index
        }.subscribe {[weak self] () in
            guard let `self` = self else { return }
            self.updateSendButton(isSend: false)
            XCGLogger.debug("计时结束")
        } onFailure: { (error) in
            XCGLogger.debug("计时失败：\(error)")
        }.disposed(by: self.disposeBag)
    }
}

extension GXMinePrWithdrawAccountVC {
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        self.requestGetSmsCode()
    }
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if (self.viewModel.aliAcccount.value ?? "").count == 0 {
            GXToast.showError(text: "请输入支付宝账号", to: self.view)
            return
        }
        if (self.viewModel.realName.value ?? "").count == 0 {
            GXToast.showError(text: "请输入真实姓名", to: self.view)
            return
        }
        if (self.viewModel.realName.value ?? "").count == 0 {
            GXToast.showError(text: "请输入验证码", to: self.view)
            return
        }
        self.requestSetWithdrawAccount()
    }
}
