//
//  GXLoginPhoneVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/15.
//

import UIKit
import RxCocoa
import RxSwift
import RxCocoaPlus
import XCGLogger
import MBProgressHUD
import PromiseKit

class GXLoginPhoneVC: GXBaseViewController {
    enum GXLoginType {
        case login
        case bindPhone
    }
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var infoTextView: GXLinkTextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var otherLoginView: UIView!
    
    private var isCountdown: Bool = false
    private var countdown: Int = 60 {
        didSet {
            self.sendCodeButton.setTitle(String(format: "%ds", countdown), for: .disabled)
        }
    }
    private lazy var viewModel: GXLoginAllViewModel = {
        return GXLoginAllViewModel()
    }()
    var loginType: GXLoginType = .login
    var tempToken: String = ""
    var completion: GXActionBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.gx_addBackBarButtonItem()
        
        self.infoTextView.gx_setMarginZero()
        self.infoTextView.attributedText = nil
        self.infoTextView.gx_appendLink(string: "I agree to the ")
        self.infoTextView.gx_appendLink(string: "\"Privacy Policy\"", color: UIColor.gx_green, urlString: "pp")
        self.infoTextView.gx_appendLink(string: " and ")
        self.infoTextView.gx_appendLink(string: "\"User Agreement\"", color: UIColor.gx_green, urlString: "ua")
        self.infoTextView.gx_appendLink(string: " \"ATT Service Terms\"", color: UIColor.gx_green, urlString: "ast")
        self.infoTextView.delegate = self
        
        self.confirmButton.isEnabled = false
        self.confirmButton.setBackgroundColor(.gx_gray, for: .disabled)
        self.confirmButton.setBackgroundColor(.gx_green, for: .normal)
        self.confirmButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
        self.sendCodeButton.isEnabled = false
        self.sendCodeButton.setTitleColor(.gx_drakGray, for: .disabled)
        self.sendCodeButton.setTitleColor(.gx_green, for: .normal)
        self.checkButton.isSelected = true
        
        let usernameValid = self.phoneTextField.rx.text.orEmpty.map {[weak self] text in
            let maxCount: Int = 11
            var string: String = text
            if text.count > maxCount {
                string = text.substring(to: maxCount)
                self?.phoneTextField.text = string
            }
            return string.count >= 10
        }
        usernameValid.bind(to: self.sendCodeButton.rx.isEnabled).disposed(by: disposeBag)
        let codeValid = self.codeTextField.rx.text.orEmpty.map {[weak self] text in
            let maxCount: Int = 6
            var string: String = text
            if text.count > maxCount {
                string = text.substring(to: maxCount)
                self?.codeTextField.text = string
            }
            return string.count == 4 || string.count == 6
        }
        let checkedValid: Observable<Bool> = self.checkButton.rx.gx_isSelected.map { $0 }
        let everythingValid = Observable.combineLatest(usernameValid, codeValid, checkedValid) { $0 && $1 && $2 }
        everythingValid.bind(to: self.confirmButton.rx.isEnabled).disposed(by: disposeBag)
        
        (self.phoneTextField.rx.textInput <-> self.viewModel.account).disposed(by: disposeBag)
        (self.codeTextField.rx.textInput <-> self.viewModel.captcha).disposed(by: disposeBag)
        
        if self.loginType == .bindPhone {
            self.otherLoginView.isHidden = true
            self.confirmButton.setTitle("Bind mobile phone number", for: .normal)
        }
        else {
            self.otherLoginView.isHidden = false
            self.confirmButton.setTitle("Login / Registration", for: .normal)
        }
    }
    
}

private extension GXLoginPhoneVC {
    
    func requestLogin() {
        self.view.endEditing(true)
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestLogin()
        }.then { model in
            GXNWProvider.login_requestUserInfo()
        }.done { model in
            MBProgressHUD.dismiss()
            NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
            self.dismissRootViewController(animated: false, completion: nil)
            self.completion?()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestSendCode() {
        self.view.endEditing(true)
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestSendCode()
        }.done {[weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss()
            self.startKeepTime()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func startKeepTime() {
        self.codeTextField.becomeFirstResponder()
        self.sendCodeButton.isEnabled = false
        self.isCountdown = true
        GXUtil.gx_countdownTimer(second: 60) {[weak self] (index) in
            guard let `self` = self else { return }
            self.countdown = index
        }.subscribe {[weak self] () in
            guard let `self` = self else { return }
            self.sendCodeButton.isEnabled = true
            self.isCountdown = false
            XCGLogger.debug("计时结束")
        } onFailure: { (error) in
            XCGLogger.debug("计时失败：\(error)")
        }.disposed(by: self.disposeBag)
    }
    func requestGoogleLogin() {
        MBProgressHUD.showLoading()
        firstly {
            GXGoogleSignInManager.shared.signIn(.promise, presenting: self)
        }.then { token in
            self.viewModel.requestGoogleLogin(token: token)
        }.done { model in
            MBProgressHUD.dismiss()
            self.gotoBinPhone(model: model)
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestAppleLogin() {
        firstly {
            GXAppleLoginManager.shared.appleLogin(.promise)
        }.ensure {
            MBProgressHUD.showLoading()
        }.then { token in
            self.viewModel.requestAppleLogin(token: token)
        }.done { model in
            MBProgressHUD.dismiss()
            self.gotoBinPhone(model: model)
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func requestBindPhone() {
        self.view.endEditing(true)
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestBindPhone(tempToken: self.tempToken)
        }.then { model in
            GXNWProvider.login_requestUserInfo()
        }.done { model in
            MBProgressHUD.dismiss()
            NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
            self.dismissRootViewController(animated: false, completion: nil)
            self.completion?()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    func gotoBinPhone(model: GXLoginModel) {
        if let token = model.data?.token, !token.isEmpty {
            GXUserManager.shared.token = model.data?.token
            NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
            self.dismissRootViewController(animated: false, completion: nil)
            self.completion?()
        }
        else if let tempToken = model.data?.tempToken, !tempToken.isEmpty {
            let vc = GXLoginPhoneVC.xibViewController().then {
                $0.loginType = .bindPhone
                $0.tempToken = tempToken
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension GXLoginPhoneVC {
    @IBAction func sendCodeButtonClicked(_ sender: UIButton) {
        self.requestSendCode()
    }
    @IBAction func checkButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        if self.loginType == .bindPhone {
            self.requestBindPhone()
        } else {
            self.requestLogin()
        }
    }
    @IBAction func googleLoginButtonClicked(_ sender: UIButton) {
        self.requestGoogleLogin()
    }
    @IBAction func appleLoginButtonClicked(_ sender: UIButton) {
        self.requestAppleLogin()
    }
}

extension GXLoginPhoneVC: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.didLinkScheme(URL.absoluteString)
        return false
    }
    func didLinkScheme(_ scheme: String) {
        switch scheme {
        case "pp":
            let vc = GXWebViewController(urlString: GXUtil.gx_h5Url(id: 2),
                                         title: "Privacy Policy")
            self.navigationController?.pushViewController(vc, animated: true)
        case "ua":
            let vc = GXWebViewController(urlString: GXUtil.gx_h5Url(id: 3),
                                         title: "User Agreement")
            self.navigationController?.pushViewController(vc, animated: true)
        case "ast":
            let vc = GXWebViewController(urlString: GXUtil.gx_h5Url(id: 1), 
                                         title: "ATT Service Terms")
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}
