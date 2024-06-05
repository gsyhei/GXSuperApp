//
//  GXLoginManager.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/5.
//

import UIKit
import XCGLogger
import MBProgressHUD

private let AUTHSDK_INFO = "esM5QIHwm0Tb+V2iqM53A94A+KzXJ1Q8CFRSL/Q7HJiHgVEM16RkE/IbDxTVvMppgbRx75jFXrI8HvwogQTkmuFq1K/k+JtM8pygyiqLDN0N5X9hmzUa56/1V8vF/iSn0GCMLYJShQ5Zo4i1TwRxNTFbUvBoahNkD+GTlnjlX6c7x2cQ4FLgMCJ7svxZGVs9IWn3HhOkYcb7gWc0IopO27xQ5tz6dD6gMpGWKMwd87irEYSWBWw98ToRTh+FePKizw9X56U8IRE="
class GXLoginManager: NSObject {
    private var controller: UIViewController?
    private var isChecked: Bool = true
    public var isShowLogin: Bool = false

    static let shared: GXLoginManager = {
        let instance = GXLoginManager()
        return instance
    }()

    class func setupAuthSDKInfo() {
        TXCommonHandler.sharedInstance().setAuthSDKInfo(AUTHSDK_INFO) { resultDic in
            XCGLogger.info("setAuthSDKInfo: \(resultDic)")
        }
    }

    class func gotoLogin(fromVC: UIViewController) {
        GXLoginManager.shared.authLogin(fromVC: fromVC)
        GXMusicWindow.shared.hideWindow()
    }

    func authLogin(fromVC: UIViewController?) {
        guard !self.isShowLogin else { return }
        guard let controller = fromVC else { return }
        self.controller = controller
        self.isShowLogin = true

        let model = self.setupAuthModel(fromVC: controller)
        TXCommonHandler.sharedInstance().getLoginToken(withTimeout: 3.0, controller: controller, model: model) { resultDic in
            XCGLogger.info("setAuthSDKInfo: \(resultDic)")
            let resultCode = resultDic["resultCode"] as? String
            switch resultCode {
            case PNSCodeLoginControllerPresentSuccess:
                break
            case PNSCodeLoginControllerPresentFailed:
                self.phoneLoginButtonClicked(nil)
            case PNSCodeCallPreLoginInAuthPage:
                break
            case PNSCodeLoginControllerClickProtocol: /// 富文本
                guard let urlName = resultDic["urlName"] as? String else { return }
                if urlName == "《用户协议》" {
                    let url = Api_WebBaseUrl + "/h5/#/agreement/7"
                    self.gotoProtocolWebVC(title: "用户协议", url: url)
                }
                else if urlName == "《隐私协议》" {
                    let url = Api_WebBaseUrl + "/h5/#/agreement/6"
                    self.gotoProtocolWebVC(title: "隐私协议", url: url)
                }
                else {
                    if let url = resultDic["url"] as? String {
                        var title = urlName.replacingOccurrences(of: "《", with: "")
                        title = title.replacingOccurrences(of: "》", with: "")
                        self.gotoProtocolWebVC(title: title, url: url)
                    }
                }
            case PNSCodeLoginControllerClickCheckBoxBtn:
                if let isChecked = resultDic["isChecked"] as? Bool {
                    self.isChecked = isChecked
                }
            case PNSCodeLoginControllerClickLoginBtn:
                if self.isChecked {
                    MBProgressHUD.showLoading(ballColor: .white)
                }
            case PNSCodeSuccess:
                MBProgressHUD.dismiss()
                let token = resultDic["token"] as? String
                self.requestAuthLogin(accessToken: token)
            case PNSCodeLoginControllerClickCancel:
                self.isShowLogin = false
            default: 
                MBProgressHUD.dismiss()
                if let code = Int(resultCode ?? "0") {
                    if code > 600002 && code <= 600026 {
                        self.phoneLoginButtonClicked(nil)
                    }
                }
                break
            }
        }
    }

    @objc func phoneLoginButtonClicked(_ sender: UIButton?) {
        if let navigationController = self.controller?.presentedViewController as? UINavigationController {
            let vc = GXLoginAllVC.xibViewController()
            vc.loginType = .login
            navigationController.pushViewController(vc, animated: true)
        }
        else if let controller = self.controller {
            let vc = GXLoginAllVC.xibViewController()
            vc.loginType = .login
            let navc = GXBaseNavigationController(rootViewController: vc)
            navc.modalPresentationStyle = .fullScreen
            controller.present(navc, animated: true)
        }
    }

    @objc func wexinLoginButtonClicked(_ sender: UIButton?) {
        GXWechatManager.shared.sendAuthRequest { code, error in
            if let code = code {
                self.requestWXLogin(code: code)
            }
            else if let err = error {
                DispatchQueue.main.async {
                    GXToast.showError(err)
                }
            }
        }
    }

    @objc func appleLoginButtonClicked(_ sender: UIButton?) {
        GXAppleManager.shared.appleLoginin { (user, error) in
            if let userID = user {
                self.requestAppleLogin(appleId: userID)
            }
            else if let err = error {
                GXToast.showError(err)
            }
        }
    }

    func gotoProtocolWebVC(title: String, url: String) {
        let navigationController = self.controller?.presentedViewController as? UINavigationController

        let vc = GXWebViewController(urlString: url, title: title)
        navigationController?.pushViewController(vc, animated: true)
    }

    func wexinLogin() {
        GXWechatManager.shared.sendAuthRequest { code, error in
            if let code = code {
                self.requestWXLogin(code: code, ballColor: .gx_black)
            }
            else if let err = error {
                DispatchQueue.main.async {
                    GXToast.showError(err)
                }
            }
        }
    }

    func appleLogin() {
        GXAppleManager.shared.appleLoginin { (user, error) in
            if let userID = user {
                self.requestAppleLogin(appleId: userID, ballColor: .gx_black)
            }
            else if let err = error {
                GXToast.showError(err)
            }
        }
    }
}

extension GXLoginManager {
    /// 本机号一键登录
    func requestAuthLogin(accessToken: String?) {
        MBProgressHUD.showLoading(ballColor: .white)
        var params: Dictionary<String, Any> = [:]
        params["accessToken"] = accessToken
        let api = GXApi.normalApi(Api_User_PhoneLogin, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            if let token = model.data as? String {
                GXUserManager.updateToken(token)
            }
            MBProgressHUD.dismiss()
            NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
            self.controller?.presentedViewController?.dismiss(animated: true)
        }, failure: { error in
            MBProgressHUD.dismiss()
            GXToast.showError(error)
        })
    }
    /// 苹果账号登录
    func requestAppleLogin(appleId: String, ballColor: UIColor = .white) {
        MBProgressHUD.showLoading(ballColor: ballColor)
        var params: Dictionary<String, Any> = [:]
        params["appleId"] = appleId
        let api = GXApi.normalApi(Api_User_AppleLogin, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            if let token = model.data as? String {
                GXUserManager.updateToken(token)
            }
            MBProgressHUD.dismiss()
            NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
            self.controller?.presentedViewController?.dismiss(animated: true)
        }, failure: { error in
            MBProgressHUD.dismiss()
            GXToast.showError(error)
        })
    }
    /// 微信账号登录
    func requestWXLogin(code: String, ballColor: UIColor = .white) {
        MBProgressHUD.showLoading(ballColor: ballColor)
        /// 缓解微信授权跳转回来时的网络中断问题
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            var params: Dictionary<String, Any> = [:]
            params["code"] = code
            let api = GXApi.normalApi(Api_User_WxLogin, params, .post)
            GXNWProvider.gx_request(api, type: GXWXLoginModel.self, success: { model in
                if let data = model.data {
                    GXWechatManager.shared.loginData = data
                    GXUserManager.updateToken(data.token)
                }
                self.requestGetUserinfo()
            }, failure: { error in
                MBProgressHUD.dismiss()
                GXToast.showError(error)
            })
        }
    }
    /// 获取本账号个人资料
    func requestGetUserinfo() {
        let api = GXApi.normalApi(Api_User_GetUserInfo, [:], .get)
        GXNWProvider.gx_request(api, type: GXUserInfoModel.self, success: { model in
            if let userInfo = model.data {
                GXUserManager.updateUser(userInfo)
            }
            if (GXUserManager.shared.user?.avatarPic.count ?? 0) == 0 ||
                (GXUserManager.shared.user?.nickName.count ?? 0) == 0 {
                GXWechatManager.shared.getUserinfo { user in
                    if let user = user {
                        self.requestUpdateUserinfo(user: user)
                    }
                    else {
                        MBProgressHUD.dismiss()
                        NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
                        self.controller?.presentedViewController?.dismiss(animated: true)
                    }
                }
            }
            else {
                MBProgressHUD.dismiss()
                NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
                self.controller?.presentedViewController?.dismiss(animated: true)
            }
        }, failure: { error in
            MBProgressHUD.dismiss()
            GXToast.showError(error)
            NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
            self.controller?.presentedViewController?.dismiss(animated: true)
        })
    }

    /// 上传微信个人资料
    func requestUpdateUserinfo(user: GXWXUserData) {
        var params: Dictionary<String, Any> = [:]
        params["avatarPic"] = user.headimgurl
        params["nickName"] = user.nickname
        let api = GXApi.normalApi(Api_User_UpdateAvatarAndNickName, params, .post)
        GXNWProvider.gx_request(api, type: GXBaseDataModel.self, success: { model in
            GXUserManager.shared.user?.avatarPic = user.headimgurl
            GXUserManager.shared.user?.nickName = user.nickname
            MBProgressHUD.dismiss()
            NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
            self.controller?.presentedViewController?.dismiss(animated: true)
        }, failure: { error in
            MBProgressHUD.dismiss()
            GXToast.showError(error)
            NotificationCenter.default.post(name: GX_NotifName_Login, object: nil)
            self.controller?.presentedViewController?.dismiss(animated: true)
        })
    }
}

extension GXLoginManager {

    func setupAuthModel(fromVC: UIViewController) -> TXCustomModel {
        let viewTop = 0.0

        let model = TXCustomModel()
        model.supportedInterfaceOrientations = .portrait
        model.navIsHidden = false
        model.navColor = .black
        if GXUserManager.shared.roleType == .publisher {
            model.suspendDisMissVC = true
            model.navBackImage = UIImage(color: .clear)!
        } else {
            model.suspendDisMissVC = false
            model.navBackImage = UIImage(named: "w_back")!
        }
        model.navTitle = NSAttributedString()
        model.preferredStatusBarStyle = .lightContent
        model.backgroundColor = .black
        model.logoImage =  UIImage(named: "l_logo_t")!
        model.logoFrameBlock = { (screenSize, superViewSize, frame) in
            let size = CGSize(width: 113, height: 105)
            let left = (superViewSize.width - size.width)/2
            let top = viewTop + 56.0
            return CGRect(origin: CGPoint(x: left, y: top), size: size)
        }

        model.sloganIsHidden = true
        model.changeBtnIsHidden = true
        model.numberColor = .white
        model.numberFont = .gx_boldFont(size: 32)
        model.numberFrameBlock = { (screenSize, superViewSize, frame) in
            var rect = frame
            rect.origin.y = superViewSize.height/2 - 60
            return rect
        }

        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_boldFont(size: 17),
            .foregroundColor: UIColor.gx_black
        ]
        model.loginBtnText = NSAttributedString(string: "一键注册/登录", attributes: attributes)
        let loginSize = CGSize(width: SCREEN_WIDTH - 48, height: 44)
        let loginNormImage = UIImage.createRoundedImage(.gx_green, size: loginSize, radius: 22) ?? UIImage()
        let loginDisaImage = UIImage.createRoundedImage(.gx_lightGray, size: loginSize, radius: 22) ?? UIImage()
        let loginHighImage = UIImage.createRoundedImage(.gx_drakGreen, size: loginSize, radius: 22) ?? UIImage()
        model.loginBtnBgImgs = [loginNormImage, loginDisaImage, loginHighImage]
        model.loginBtnFrameBlock = { (screenSize, superViewSize, frame) in
            var rect = frame
            rect.origin.y = superViewSize.height/2
            return rect
        }

        model.checkBoxIsChecked = true
        model.checkBoxWH = 18
        model.checkBoxVerticalCenter = false
        model.expandAuthPageCheckedScope = true
        model.checkBoxImages = [UIImage(named: "l_check_l")!, UIImage(named: "l_checked_d")!]
        model.checkBoxImageEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: -2)
        model.privacyOperatorPreText = "《"
        model.privacyOperatorSufText = "》"
        model.privacyOne = ["《用户协议》", ""]
        model.privacyTwo = ["《隐私协议》", ""]
        model.privacyConectTexts = ["和"," "," "] 
        model.privacyVCIsCustomized = true
        model.privacyAlignment = .center

        let customView = self.setupAuthOtherView()
        model.customViewBlock = { superCustomView in
            superCustomView.addSubview(customView)
        }
        model.customViewLayoutBlock = { (screenSize, contentViewFrame, navFrame, titleBarFrame,
                                         logoFrame, sloganFrame, numberFrame, loginFrame,
                                         changeBtnFrame, privacyFrame) in
            var rect = customView.frame
            rect.origin.y = privacyFrame.origin.y - rect.height
            customView.frame = rect
        }

        return model
    }

    func setupAuthOtherView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 90.0))
        let titleLabel = UILabel()
        titleLabel.text = "其他登陆方式"
        titleLabel.textColor = .gx_gray
        titleLabel.textAlignment = .center
        titleLabel.font = .gx_font(size: 13)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(4)
        }

        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            let wxLoginButton = UIButton(type: .custom)
            wxLoginButton.setImage(UIImage(named: "l_weixin_d"), for: .normal)
            view.addSubview(wxLoginButton)
            wxLoginButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
            }
            wxLoginButton.addTarget(self, action: #selector(self.wexinLoginButtonClicked(_:)), for: .touchUpInside)

            let appleLoginButton = UIButton(type: .custom)
            appleLoginButton.setImage(UIImage(named: "l_apple_d"), for: .normal)
            view.addSubview(appleLoginButton)
            appleLoginButton.snp.makeConstraints { make in
                make.left.equalTo(wxLoginButton.snp.right).offset(32)
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
            }
            appleLoginButton.addTarget(self, action: #selector(self.appleLoginButtonClicked(_:)), for: .touchUpInside)

            let smsLoginButton = UIButton(type: .custom)
            smsLoginButton.setImage(UIImage(named: "l_phone_l"), for: .normal)
            view.addSubview(smsLoginButton)
            smsLoginButton.snp.makeConstraints { make in
                make.right.equalTo(wxLoginButton.snp.left).offset(-32)
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
            }
            smsLoginButton.addTarget(self, action: #selector(self.phoneLoginButtonClicked(_:)), for: .touchUpInside)
        }
        else {
            let appleLoginButton = UIButton(type: .custom)
            appleLoginButton.setImage(UIImage(named: "l_apple_d"), for: .normal)
            view.addSubview(appleLoginButton)
            appleLoginButton.snp.makeConstraints { make in
                make.left.equalTo(view.snp.centerX).offset(16)
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
            }
            appleLoginButton.addTarget(self, action: #selector(self.appleLoginButtonClicked(_:)), for: .touchUpInside)

            let smsLoginButton = UIButton(type: .custom)
            smsLoginButton.setImage(UIImage(named: "l_phone_l"), for: .normal)
            view.addSubview(smsLoginButton)
            smsLoginButton.snp.makeConstraints { make in
                make.right.equalTo(view.snp.centerX).offset(-16)
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
            }
            smsLoginButton.addTarget(self, action: #selector(self.phoneLoginButtonClicked(_:)), for: .touchUpInside)
        }

        return view
    }
}
