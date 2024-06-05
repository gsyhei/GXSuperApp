//
//  GXWechatManager.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/8.
//

import UIKit
import XCGLogger
import Alamofire

/// 微信appId
let GX_WX_APPID = "wx4e5435254fc334e9"
/// 微信appSecret
let GX_WX_APPSECRET = "87c0e892eecdbf7ed60c95efd5df2b42"
/// 微信Universal Links
let GX_WX_UNIVERSAL_LINK = "https://www.heiradio.cn/app/"

class GXWechatManager: NSObject {
    private var payCompletion: GXActionBlockItem<GXError?>?
    private var loginCompletion: GXActionBlockItem2<String?, GXError?>?
    private var shareCompletion: GXActionBlockItem<GXError?>?

    public var loginData: GXWXLoginData?
    private var code: String = ""
    private var token: String {
        return loginData?.accessToken ?? ""
    }
    private var openid: String {
        return loginData?.openid ?? ""
    }
    static let shared: GXWechatManager = {
        let instance = GXWechatManager()
        return instance
    }()

    /// 唤起支付
    func payOrder(params: Dictionary<String, Any>, completion: GXActionBlockItem<GXError?>?) {
        self.payCompletion = completion
        let request = PayReq()
        request.partnerId = params["merchantId"] as? String ?? ""
        request.prepayId = params["prepayId"] as? String ?? ""
        request.package = "Sign=WXPay"
        request.nonceStr = params["noncestr"] as? String ?? ""
        request.timeStamp = UInt32(params["timestamp"] as? String ?? "") ?? 0
        request.sign = params["signature"] as? String ?? ""
        WXApi.send(request)
    }

    /// 唤起登录
    func sendAuthRequest(completion: GXActionBlockItem2<String?, GXError?>?) {
        self.loginCompletion = completion
        let request = SendAuthReq()
        request.scope = "snsapi_userinfo"
        request.state = "heivibe_wx_auth"
        request.nonautomatic = false
        WXApi.send(request)
    }

    /// 微信分享
    func sharedWeb(activityId: Int?, activityName: String?, activityTypeName: String?, image: UIImage? = nil, scene: WXScene, completion: GXActionBlockItem<GXError?>?) {
        self.shareCompletion = completion
        let webpage = WXWebpageObject()
        webpage.webpageUrl = Api_WebBaseUrl + "/h5/#/share/\(activityId ?? 0)"
        let media = WXMediaMessage()
        media.title = activityName ?? ""
        media.description = activityTypeName ?? ""
        media.thumbData = image?.dataForCompression(to: CGSizeMake(150, 150), resizeByte: 1024 * 50)
        media.mediaObject = webpage
        let request = SendMessageToWXReq()
        request.message = media
        request.scene = Int32(scene.rawValue)
        WXApi.send(request)
    }

    /// 获取token
    func getAccessToken() {
        var urlString = "https://api.weixin.qq.com/sns/oauth2/access_token?"
        urlString.append("appid=\(GX_WX_APPID)&secret=\(GX_WX_APPSECRET)&code=\(self.code)&grant_type=authorization_code")
        XCGLogger.info("WX getAccessToken url: \(urlString)")
        AF.request(urlString, method: .get).responseString(completionHandler: { response in
            switch response.result {
            case .success(let result):
                print(result)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    /// 获取个人信息
    func getUserinfo(completion: GXActionBlockItem<GXWXUserData?>?) {
        let urlString = "https://api.weixin.qq.com/sns/userinfo?access_token=\(self.token)&openid=\(self.openid)&lang=zh_CN"
        XCGLogger.info("WX getUserinfo url: \(urlString)")
        AF.request(urlString, method: .get).responseString(completionHandler: { response in
            switch response.result {
            case .success(let result):
                XCGLogger.info("WX getUserinfo = \(result)")

                let chatstr = result.cString(using: .isoLatin1)
                let string = String(cString: chatstr ?? [], encoding: .utf8)
                if let json = string?.jsonValueDecoded() as? Dictionary<String, Any> {
                    let user = GXWXUserData.deserialize(from: json)
                    user?.headimgurl = user?.headimgurl.replacingOccurrences(of: "\\", with: "") ?? ""
                    completion?(user)
                } else {
                    completion?(nil)
                }
                XCGLogger.info("WX getUserinfo = \(string ?? "")")
            case .failure(let error):
                completion?(nil)
                XCGLogger.info("WX getUserinfo error = \(error)")
            }
        })
    }

}

extension GXWechatManager: WXApiDelegate {
    func onReq(_ req: BaseReq) {
        XCGLogger.info("GXWechatManager onReq type = \(req.type)")
        if let request = req as? LaunchFromWXReq {
            let dict = request.message.messageExt?.jsonValueDecoded()
            guard let dict = dict as? Dictionary<String, Any> else { return }
            guard let activityIdStr = dict["activityId"] as? String else { return }
            guard let activityId = Int(activityIdStr) else { return }
            let model = GXNotificationBodyModel()
            model.activityId = activityId
            model.targetType = 1 //参与者端
            model.messageType = 11
            if GXUserManager.shared.isLogin {
                GXUserManager.shared.notificationModel = model
                NotificationCenter.default.post(name: GX_NotifName_ClickNotification, object: nil)
            }
        }
    }

    func onResp(_ resp: BaseResp) {
        // 支付响应
        if let response = resp as? PayResp {
            if response.errCode == WXSuccess.rawValue {
                self.payCompletion?(nil)
            } else {
                let error = GXError(code: Int(response.errCode), info: response.errStr)
                self.payCompletion?(error)
            }
        }
        // 登录响应
        else if let response = resp as? SendAuthResp {
            if response.errCode == WXSuccess.rawValue {
                self.code = response.code ?? ""
                self.loginCompletion?(response.code, nil)
            } else {
                let errStr = (response.errStr.count > 0) ? response.errStr:"授权失败"
                let error = GXError(code: Int(response.errCode), info: errStr)
                self.loginCompletion?(nil, error)
            }
        }
        // 分享
        else if let response = resp as? SendMessageToWXResp {
            if response.errCode == WXSuccess.rawValue {
                self.shareCompletion?(nil)
            } else {
                let error = GXError(code: Int(response.errCode), info: response.errStr)
                self.shareCompletion?(error)
            }
        }
    }

}
