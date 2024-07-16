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
        let checkedValid: Observable<Bool> = self.checkButton.rx.rx_isSelected
        let everythingValid = Observable.combineLatest(usernameValid, codeValid, checkedValid) { $0 && $1 && $2 }
        everythingValid.bind(to: self.confirmButton.rx.isEnabled).disposed(by: disposeBag)
        
        (self.phoneTextField.rx.textInput <-> self.viewModel.account).disposed(by: disposeBag)
        (self.codeTextField.rx.textInput <-> self.viewModel.captcha).disposed(by: disposeBag)
    }
    
}

private extension GXLoginPhoneVC {
    
    func requestLogin() {
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
}

extension GXLoginPhoneVC {
    @IBAction func sendCodeButtonClicked(_ sender: UIButton) {
        self.requestSendCode()
    }
    @IBAction func checkButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        self.requestLogin()
    }
    @IBAction func googleLoginButtonClicked(_ sender: UIButton) {

    }
    @IBAction func appleLoginButtonClicked(_ sender: UIButton) {

    }
}

extension GXLoginPhoneVC: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.didLinkScheme(URL.absoluteString)
        return false
    }
    func didLinkScheme(_ scheme: String) {
        
    }
}
