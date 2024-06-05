//
//  GXUserManager.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/27.
//

import UIKit
import XCGLogger
import CoreLocation

class GXUserManager: NSObject {

    /// 角色类型
    enum GXRoleType: Int {
        /// 参与者
        case participant = 1
        /// 发布者
        case publisher   = 2
    }

    static let shared: GXUserManager = {
        let instance = GXUserManager()
        return instance
    }()

    public var registrationID: String?
    public var tabRedPointData: GXTabRedPointData?
    public var notificationModel: GXNotificationBodyModel?
    
    public var isGetUser: Bool = false
    public var isLogin: Bool {
        return self.token != nil
    }

    public lazy var token: String? = {
        return UserDefaults.standard.string(forKey: GX_USER_TOKEN_KEY)
    }()

    public lazy var user: GXUserInfoData? = {
        return nil
    }()

    public lazy var roleType: GXRoleType = {
        return GXRoleType(rawValue:UserDefaults.standard.integer(forKey: GX_ROLE_TYPE_KEY)) ?? .participant
    }()

    public lazy var city: String = {
        return UserDefaults.standard.string(forKey: GX_CITY_KEY) ?? "北京"
    }()

    public lazy var location: CLLocationCoordinate2D? = {
        if let coordinateArray = UserDefaults.standard.array(forKey: GX_LOCATION_KEY) as? [CLLocationDegrees] {
            if coordinateArray.count == 2 {
                return CLLocationCoordinate2D(latitude: coordinateArray[0], longitude: coordinateArray[1])
            }
        }
        return nil
    }()

    public lazy var searchHistory: [String]? = {
        return UserDefaults.standard.array(forKey: GX_SEARCH_HISTORY_KEY) as? [String]
    }()

}

extension GXUserManager {
    /// 更新token
    class func updateToken(_ token: String?) {
        GXUserManager.shared.token = token
        GXLoginManager.shared.isShowLogin = false
        if let letToken = token {
            UserDefaults.standard.setValue(letToken, forKey: GX_USER_TOKEN_KEY)
            UserDefaults.standard.synchronize()
            GXApiUtil.requestUpdateCid()
        }
        else {
            UserDefaults.standard.removeObject(forKey: GX_USER_TOKEN_KEY)
            UserDefaults.standard.synchronize()
        }
    }

    /// 更新roleType
    class func updateRoleType(_ type: GXRoleType?) {
        if let letType = type {
            GXUserManager.shared.roleType = letType
            UserDefaults.standard.setValue(letType.rawValue, forKey: GX_ROLE_TYPE_KEY)
        }
        else {
            UserDefaults.standard.removeObject(forKey: GX_ROLE_TYPE_KEY)
        }
        UserDefaults.standard.synchronize()
    }

    /// 更新user
    class func updateUser(_ user: GXUserInfoData?) {
        GXUserManager.shared.user = user
    }

    /// 更新城市
    class func updateCity(_ city: String?) {
        if let letCity = city {
            GXUserManager.shared.city = letCity
            UserDefaults.standard.setValue(letCity, forKey: GX_CITY_KEY)
        }
        else {
            UserDefaults.standard.removeObject(forKey: GX_CITY_KEY)
        }
        UserDefaults.standard.synchronize()
    }

    /// 更新经纬度
    class func updateLocation(_ location: CLLocationCoordinate2D?) {
        GXUserManager.shared.location = location
        if let letLocation = location {
            let locationArr = [letLocation.latitude, letLocation.longitude]
            UserDefaults.standard.setValue(locationArr, forKey: GX_LOCATION_KEY)
        } else {
            UserDefaults.standard.removeObject(forKey: GX_LOCATION_KEY)
        }
        UserDefaults.standard.synchronize()
    }

    /// 更新搜索历史
    class func updateSearchHistory(_ searchHistory: [String]?) {
        if let letSearchHistory = searchHistory {
            let count = letSearchHistory.count
            if count > 5 {
                let newSearchHistory = letSearchHistory[count-5..<count]
                GXUserManager.shared.searchHistory = Array(newSearchHistory)
                UserDefaults.standard.setValue(Array(newSearchHistory), forKey: GX_SEARCH_HISTORY_KEY)
            }
            else {
                GXUserManager.shared.searchHistory = searchHistory
                UserDefaults.standard.setValue(letSearchHistory, forKey: GX_SEARCH_HISTORY_KEY)
            }
        } else {
            GXUserManager.shared.searchHistory = searchHistory
            UserDefaults.standard.removeObject(forKey: GX_SEARCH_HISTORY_KEY)
        }
        UserDefaults.standard.synchronize()
    }

    /// 添加搜索历史
    class func addSearchHistory(_ history: String?) {
        guard let historyText = history else { return }
        if var searchHistory = GXUserManager.shared.searchHistory {
            if !searchHistory.contains(where: { $0 == historyText }) {
                searchHistory.append(historyText)
                GXUserManager.updateSearchHistory(searchHistory)
            }
        }
        else {
            GXUserManager.updateSearchHistory([historyText])
        }
    }

    /// 登出
    class func logout() {
        GXUserManager.updateToken(nil)
        GXUserManager.updateUser(nil)
    }
}

extension GXUserManager {
    /// 判断是否实名认证
    class func isRealnameApprove() -> Bool {
        if (GXUserManager.shared.user?.realnameFlag ?? 0) == 1 {
            return true
        }
        return false
    }
    /// 判断是否绑定手机
    class func isBindPhone() -> Bool {
        if (GXUserManager.shared.user?.phone.count ?? 0) == 0 {
            return false
        }
        return true
    }
    /// 判断个人资料是否完善
    class func isPersonalInfoPerfect() -> Bool {
        if (GXUserManager.shared.user?.nickName.count ?? 0) == 0 {
            return false
        }
        if (GXUserManager.shared.user?.userMale ?? 0) == 0 {
            return false
        }
        return true
    }
    /// 去发布
    class func gotoPublish(navc: GXBaseNavigationController?) {
        if GXUserManager.isBindPhone() {
            if GXUserManager.isRealnameApprove() {
                let vc = GXPublishStep1VC.createVC()
                vc.hidesBottomBarWhenPushed = true
                navc?.pushViewController(vc, animated: true)
            }
            else {
                let publishAction: GXActionBlockItem<UIViewController?> = { formVC in
                    formVC?.dismiss(animated: true)
                    let vc = GXPublishStep1VC.createVC()
                    vc.hidesBottomBarWhenPushed = true
                    navc?.pushViewController(vc, animated: true)
                }
                let vc = GXMinePtRealNameVC.xibViewController()
                vc.completion = publishAction
                let toNavc = GXBaseNavigationController(rootViewController: vc)
                navc?.present(toNavc, animated: true)
            }
        }
        else {
            let publishAction: GXActionBlockItem<UIViewController?> = { formVC in
                formVC?.dismiss(animated: true)
                let vc = GXPublishStep1VC.createVC()
                vc.hidesBottomBarWhenPushed = true
                navc?.pushViewController(vc, animated: true)
            }
            let realNameAction: GXActionBlockItem<UIViewController?> = { formVC in
                let vc = GXMinePtRealNameVC.xibViewController()
                vc.completion = publishAction
                formVC?.navigationController?.pushViewController(vc, animated: true)
            }
            let vc = GXLoginAllVC.xibViewController()
            vc.loginType = .bindPhone
            vc.completion = { formVC in
                if GXUserManager.isRealnameApprove() {
                    publishAction(formVC)
                } else {
                    realNameAction(formVC)
                }
            }
            let toNavc = GXBaseNavigationController(rootViewController: vc)
            navc?.present(toNavc, animated: true)
        }
    }
    /// 去报名
    class func gotoSignUp(navc: GXBaseNavigationController?) -> Bool {
        if GXUserManager.isBindPhone() {
            if GXUserManager.isPersonalInfoPerfect() {
                return true
            }
            else {
                let vc = GXMinePtEditInfoVC.xibViewController()
                vc.completion = { formVC in
                    formVC?.dismiss(animated: true)
                }
                let toNavc = GXBaseNavigationController(rootViewController: vc)
                navc?.present(toNavc, animated: true)
            }
        }
        else {
            let editInfoAction: GXActionBlockItem<UIViewController?> = { formVC in
                let vc = GXMinePtEditInfoVC.xibViewController()
                vc.completion = { formVC in
                    formVC?.dismiss(animated: true)
                }
                formVC?.navigationController?.pushViewController(vc, animated: true)
            }
            let vc = GXLoginAllVC.xibViewController()
            vc.loginType = .bindPhone
            vc.completion = { formVC in
                if GXUserManager.isPersonalInfoPerfect() {
                    formVC?.dismiss(animated: true)
                } else {
                    editInfoAction(formVC)
                }
            }
            let toNavc = GXBaseNavigationController(rootViewController: vc)
            navc?.present(toNavc, animated: true)
        }
        return false
    }
}
