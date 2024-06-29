//
//  GXLoginAllVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/28.
//

import UIKit
import XCGLogger
import MBProgressHUD

class GXLoginAllVC: GXBaseViewController {
    enum GXLoginType {
        case login
        case bindPhone
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: GXBaseTableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var infoTextView: GXLinkTextView!
    @IBOutlet weak var errorLabel: UILabel!

    var loginType: GXLoginType = .login
    var sendCodeCompletion: GXActionBlock?
    var completion: GXActionBlockItem<UIViewController?>?
    
    private lazy var viewModel: GXLoginAllViewModel = {
        return GXLoginAllViewModel()
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
    }

    override func setupViewController() {
        self.view.backgroundColor = .white
        self.gx_addBackBarButtonItem()
        
        if self.loginType == .login {
            self.titleLabel.text = "登录/注册"
            self.confirmButton.setTitle("确认", for: .normal)
        }
        else {
            self.titleLabel.text = "绑定手机号"
            self.confirmButton.setTitle("一键绑定", for: .normal)
        }

        self.errorLabel.text = nil
        self.confirmButton.setBackgroundColor(.gx_green, for: .normal)
        self.checkButton.isSelected = true

        self.infoTextView.gx_setMarginZero()
        self.infoTextView.gx_appendLink(string: "《用户协议》", color: UIColor.gx_blue, urlString: "yhxy")
        self.infoTextView.gx_appendLink(string: "《隐私协议》", color: UIColor.gx_blue, urlString: "yszc")

        self.infoTextView.delegate = self

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
        self.tableView.isScrollEnabled = false
        self.tableView.rowHeight = 50.0
        self.tableView.register(cellType: GXLoginInputCell.self)
    }

    @IBAction func checkButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)

        if !self.checkButton.isSelected {
            self.errorLabel.text = "请先同意《用户协议》《隐私协议》。"
            return
        }
        let account: String = self.viewModel.account.value ?? ""
        if account.count == 0 {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "请输入手机号"
            return
        }
        if !account.isMobile {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "请输入11位手机号"
            return
        }
        let captcha: String = self.viewModel.captcha.value ?? ""
        if captcha.count == 0 {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "请输入验证码"
            return
        }

        if self.loginType == .login {
            self.errorLabel.isHidden = true
            MBProgressHUD.showLoading(to: self.view)
            self.viewModel.requestLogin {[weak self] in
                MBProgressHUD.dismiss(for: self?.view)
                NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
                self?.dismissRootViewController(animated: false, completion: nil)
                self?.completion?(self)
            } failure: {[weak self] error in
                MBProgressHUD.dismiss(for: self?.view)
                GXToast.showError(error, to: self?.view)
            }
        }
        else {
            self.errorLabel.isHidden = true
            MBProgressHUD.showLoading(to: self.view)
            self.viewModel.requestBindPhone {[weak self] in
                MBProgressHUD.dismiss(for: self?.view)
                GXToast.showSuccess(text: "手机号绑定成功")
                self?.completion?(self)
            } failure: {[weak self] error in
                MBProgressHUD.dismiss(for: self?.view)
                GXToast.showError(error, to: self?.view)
            }
        }
    }

}

extension GXLoginAllVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: GXLoginInputCell.self)
        cell.inputTextField.delegate = self
        if indexPath.row == 0 {
            cell.setInput(type: .username, placeholder: "请输入手机号码", input: self.viewModel.account)
        }
        else {
            cell.setInput(type: .code, placeholder: "请输入验证码", input: self.viewModel.captcha)
            cell.sendCodeCompleteBlock = { [weak self] block in
                self?.requestSendCode()
                self?.sendCodeCompletion = block
            }
        }
        return cell
    }
}

extension GXLoginAllVC: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.didLinkScheme(URL.absoluteString)
        return false
    }

    func didLinkScheme(_ scheme: String) {
        
    }
}

extension GXLoginAllVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.errorLabel.text = nil
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let account: String = self.viewModel.account.value ?? ""
        if account.count == 0 {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "请输入手机号"
            return
        }
        if !account.isMobile {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "请输入11位手机号"
            return
        }
        let captcha: String = self.viewModel.captcha.value ?? ""
        if captcha.count == 0 {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "请输入验证码"
            return
        }
    }
}

private extension GXLoginAllVC {

    func requestSendCode() {
        self.view.endEditing(true)

        let account: String = self.viewModel.account.value ?? ""
        if account.count == 0 {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "请输入手机号"
            return
        }
        if !account.isMobile {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "请输入11位手机号"
            return
        }

        self.errorLabel.isHidden = true
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestSendCode {[weak self] in
            MBProgressHUD.dismiss(for: self?.view, animated: false)
            GXToast.showSuccess(text: "验证码已发送", to: self?.view)
            self?.sendCodeCompletion?()
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            self?.errorLabel.isHidden = false
            self?.errorLabel.text = error.localizedDescription
        }
    }
}
