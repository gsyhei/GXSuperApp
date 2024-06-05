//
//  GXTabBarParticipantC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/27.
//

import UIKit
import XCGLogger
import CoreLocation
import RxSwift

class GXTabBarParticipantC: UITabBarController {
    let disposeBag = DisposeBag()
    private lazy var normalImageNames : [String] = {
        return ["t_home_normal", "t_calendar_normal", "t_tickets_normal", "t_messages_normal", "t_mine_normal"]
    }()
    private lazy var selectedImageNames : [String] = {
        return ["t_home_select", "t_calendar_select", "t_tickets_select", "t_messages_select", "t_mine_select"]
    }()
    private lazy var titleNames : [String] = {
        return ["首页", "日历", "票夹", "消息", "我的"]
    }()
    private var isLoadLocation: Bool = false

    private lazy var redPointView: UIView = {
        return UIView(frame: CGRect(origin: .zero, size: CGSizeMake(6, 6))).then {
            $0.backgroundColor = .gx_red
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 3.0
        }
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        GXApiUtil.requestGetTabRedPoint()
        self.clickNotification()

        GXLocationManager.shared.requestGeocodeCompletion {[weak self] (isAuth, cityName, location) in
            XCGLogger.info("已定位到当前城市：\(cityName ?? "未知")")
            guard let `self` = self else { return }
            guard isAuth else {
                self.showAlertNotLocation()
                return
            }
            guard let city = cityName else { return }
            guard !self.isLoadLocation else { return }
            guard !city.contains(find: GXUserManager.shared.city) else { return }
            self.isLoadLocation = true
            self.showLocationChange(city: city, location: location)
            GXApiUtil.requestUpdateLocation()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.delegate = self

        self.addChild(GXParticipantHomeVC.xibViewController(),
                      title: self.titleNames[0],
                      imageName: self.normalImageNames[0],
                      selectedImageName: self.selectedImageNames[0])
        self.addChild(GXParticipantCalendarVC.xibViewController(),
                      title: self.titleNames[1],
                      imageName: self.normalImageNames[1],
                      selectedImageName: self.selectedImageNames[1])
        self.addChild(GXTicketsVC.xibViewController(),
                      title: self.titleNames[2],
                      imageName: self.normalImageNames[2],
                      selectedImageName: self.selectedImageNames[2])
        self.addChild(GXConversationListVC(),
                      title: self.titleNames[3],
                      imageName: self.normalImageNames[3],
                      selectedImageName: self.selectedImageNames[3])
        self.addChild(GXMinePtVC(),
                      title: self.titleNames[4],
                      imageName: self.normalImageNames[4],
                      selectedImageName: self.selectedImageNames[4])

        GXMusicWindow.shared.showWindow(isLoad: true)

        NotificationCenter.default.rx
            .notification(GX_NotifName_UpdateTabRedPoint)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.updateTabbarRedPoint()
            }).disposed(by: disposeBag)
        NotificationCenter.default.rx
            .notification(GX_NotifName_ClickNotification)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.clickNotification()
            }).disposed(by: disposeBag)
    }

    func showLocationChange(city: String, location: CLLocation?) {
        let title = "地理位置变更\n“HEI VIBE”定位您在\(city)，是否切换？"
        GXUtil.showAlert(to: self.view, title: title, actionTitle: "切换") { alert, index in
            guard index == 1 else { return }
            GXUserManager.updateCity(city)
            if let letLocation = location {
                GXUserManager.updateLocation(letLocation.coordinate)
            }
            NotificationCenter.default.post(name: GX_NotifName_ChangeCity, object: nil)
        }
    }

    func updateTabbarRedPoint(index: Int = 3) {
        self.redPointView.removeFromSuperview()
        if (GXUserManager.shared.tabRedPointData?.messageRedPoint ?? false) {
            let itemWidth = self.tabBar.width / CGFloat(self.titleNames.count)
            let left = itemWidth * CGFloat(index) + (itemWidth - 24)/2 - 4
            self.redPointView.frame.origin = CGPoint(x: left, y: 28.0)
            self.tabBar.addSubview(self.redPointView)
        }
    }

    func showAlertNotLocation() {
        let title = "您没有开启位置权限，是否去App设置开启？"
        GXUtil.showAlert(to: self.view, title: title, actionTitle: "去设置") { alert, index in
            guard index == 1 else { return }
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, completionHandler: nil)
            }
        }
    }

}

extension GXTabBarParticipantC {
    private func addChild(_ vc: UIViewController, title: String, imageName: String, selectedImageName:String) {
        let childVC = GXBaseNavigationController(rootViewController: vc)
        childVC.title = title
        childVC.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        childVC.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal)
        self.addChild(childVC)
    }

    func setChildItem(selectedImageName: String, at index: Int) {
        guard (self.viewControllers?.count ?? 0) > index else { return }
        if let childVC = self.viewControllers?[index] {
            childVC.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal)
        }
    }
}

extension GXTabBarParticipantC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let shouldSelectIndex = tabBarController.viewControllers?.firstIndex(of: viewController) {
            switch shouldSelectIndex {
            case 2:
                if !GXUserManager.shared.isLogin {
                    GXLoginManager.gotoLogin(fromVC: tabBarController)
                    return false
                }
            case 3:
                if !GXUserManager.shared.isLogin {
                    GXLoginManager.gotoLogin(fromVC: tabBarController)
                    return false
                }
            case 4:
                if !GXUserManager.shared.isLogin {
                    GXLoginManager.gotoLogin(fromVC: tabBarController)
                    return false
                }
            default: break
            }
        }
        return true
    }
}

extension GXTabBarParticipantC {
    func clickNotification() {
        guard let model = GXUserManager.shared.notificationModel else { return }
        guard model.targetType == GXUserManager.shared.roleType.rawValue else {
            if GXUserManager.shared.roleType == .publisher {
                GXUserManager.updateRoleType(.participant)
            } else {
                GXUserManager.updateRoleType(.publisher)
            }
            GXAppDelegate?.changeRoleType()
            return
        }
        var navc = self.selectedViewController as? GXBaseNavigationController
        if let presentedVC = navc?.viewControllers.last?.presentedViewController {
            presentedVC.dismiss(animated: false)
        }
        navc?.popToRootViewController(animated: false)
        if navc == nil {
            navc = self.viewControllers?.first as? GXBaseNavigationController
        }
        guard let navc = navc else { return }
        
        /**
         * 消息类型 1-活动咨询消息 2-活动回顾信息 3-活动咨询消息回复 4-报名成功 5-参与者获奖信息
         *        6-活动问卷 7-工作汇报 8-禁用活动 9-禁用活动用户端 10-审核活动通过
         */
        switch model.messageType {
        case 1: /// 发布者端
            break
        case 2: /// 发布者端
            break
        case 3:
            let vc = GXChatViewController(messageType: 1, activityId: model.activityId, title: nil)
            let nav = GXBaseNavigationController(rootViewController: vc)
            self.gx_present(nav, style: .push)
        case 4:
            self.selectedIndex = 2
        case 5:
            let vc = GXPtEventDetailVC.createVC(eventId: model.targetId)
            vc.hidesBottomBarWhenPushed = true
            navc.pushViewController(vc, animated: true)
        case 6:
            let vc = GXPtQuestionnaireSubmitVC.createVC(questionaireId: model.targetId)
            vc.hidesBottomBarWhenPushed = true
            navc.pushViewController(vc, animated: true)
        case 7: /// 发布者端
            break
        case 8: /// 发布者端
            break
        case 9:
            self.selectedIndex = 2
        case 10: /// 发布者端
            break
        case 11:
            let vc = GXParticipantActivityDetailVC.createVC(activityId: model.activityId)
            vc.hidesBottomBarWhenPushed = true
            navc.pushViewController(vc, animated: true)
        default: break
        }
        GXUserManager.shared.notificationModel = nil
    }
}

