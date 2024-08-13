//
//  GXAppleManager.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/21.
//

import UIKit
import AuthenticationServices
import XCGLogger
import PromiseKit

class GXAppleManager: NSObject {

    static let shared: GXAppleManager = {
        let instance = GXAppleManager()
        return instance
    }()
    private var completion: GXActionBlockItem2<String?, GXError?>?

    deinit {
        NotificationCenter.default.removeObserver(self, name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
    }

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleSignInWithAppleStateChanged(noti:)), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
    }

    func appleLogin(completion: @escaping GXActionBlockItem2<String?, GXError?>) {
        self.completion = completion

        let requests = [ASAuthorizationAppleIDProvider().createRequest()]
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @objc func handleSignInWithAppleStateChanged(noti: Notification) {
        XCGLogger.info("用户更换当前appleID...")
    }

}

extension GXAppleManager {
    func appleLogin(_: PMKNamespacer) -> Promise<String> {
        return Promise { seal in
            self.appleLogin { token, error in
                if let error = error {
                    seal.reject(error)
                }
                else {
                    seal.fulfill(token ?? "")
                }
            }
        }
    }
}

extension GXAppleManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func authorizationController(controller:ASAuthorizationController, didCompleteWithAuthorization authorization:ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 苹果用户仅有标识符，该值在同一个开发者账号下的一切 App 下是一样的，开发者能够用该仅有标识符与自己后台体系的账号体系绑定起来。
            let user = appleIDCredential.user
            // 苹果用户信息 假如授权过，可能无法再次获取该信息
            // let fullName = appleIDCredential.fullName
            // let email = appleIDCredential.email
            // 服务器验证需要运用的参数
            // let authorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: String.Encoding.utf8)!
             let identityToken = String(data: appleIDCredential.identityToken!, encoding: String.Encoding.utf8)!
            // 对接登录接口，处理用户登录操作
            self.completion?(identityToken, nil)
        }
        else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            let user = passwordCredential.user
            // let password = passwordCredential.password
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let letErr = error as? ASAuthorizationError {
            var errorMsg = ""
            switch letErr.code {
            case .unknown:
                errorMsg = "授权恳求失利未知原因"
            case .canceled:
                errorMsg = "用户取消了授权恳求"
            case .invalidResponse:
                errorMsg = "授权恳求响应无效"
            case .notHandled:
                errorMsg = "未能处理授权恳求"
            case .failed:
                errorMsg = "授权恳求失利"
            case .notInteractive:
                errorMsg = "授权恳求未处理"
            @unknown default:
                errorMsg = "授权恳求失利其他原因"
            }
            XCGLogger.info("ASAuthorizationError: \(errorMsg)")
            let newError = GXError(code: letErr.code.rawValue, info: errorMsg)
            self.completion?(nil, newError)
        }
        else {
            let newError = GXError(code: -1000, info: "授权失败")
            self.completion?(nil, newError)
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (GXAppDelegate?.window)!
    }

}
