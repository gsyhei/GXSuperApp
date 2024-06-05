//
//  GXTabBarPublisherC.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/27.
//

import UIKit
import Popover
import RxSwift

class GXTabBarPublisherC: UITabBarController {
    private lazy var normalImageNames : [String] = {
        return ["t_home_normal", "t_publish_normal", "t_messages_normal", "t_mine_normal"]
    }()
    private lazy var selectedImageNames : [String] = {
        return ["t_home_select", "t_publish_normal", "t_messages_select", "t_mine_select"]
    }()
    private lazy var titleNames : [String] = {
        return ["首页", "发布", "消息", "我的"]
    }()
    let disposeBag = DisposeBag()

    private var isShowPopover: Bool {
        get {
            return UserDefaults.standard.bool(forKey: GX_PRSHOW_POPOVER_KEY)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: GX_PRSHOW_POPOVER_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    private lazy var redPointView: UIView = {
        return UIView(frame: CGRect(origin: .zero, size: CGSizeMake(6, 6))).then {
            $0.backgroundColor = .gx_red
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 3.0
        }
    }()

    private lazy var popover: Popover = {
        let color = UIColor(white: 0, alpha: 0.1)
        let size = CGSize(width: 16.0, height: 8.0)
        let options:[PopoverOption] = [.type(.up),.sideEdge(5.0),.blackOverlayColor(color),.arrowSize(size),.animationIn(0.3)]

        return Popover(options: options)
    }()

    private lazy var publishView: UIView = {
        return UIView().then {
            $0.frame = self.publishButton.bounds
            $0.backgroundColor = .clear
            $0.addSubview(self.publishButton)
        }
    }()

    private lazy var publishButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.frame = CGRect(x: 0, y: 0, width: 176, height: 44)
            $0.titleLabel?.font = .gx_boldFont(size: 15)
            $0.setTitleColor(.gx_black, for: .normal)
            $0.setTitle("发布您的第一个活动", for: .normal)
            $0.setImage(UIImage(named: "a_po_icon"), for: .normal)
            $0.addTarget(self, action: #selector(self.gotoPublish), for: .touchUpInside)
        }
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        GXApiUtil.requestGetTabRedPoint()
        self.clickNotification()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.delegate = self

        self.addChild(GXPublishHomeVC.xibViewController(),
                      title: self.titleNames[0],
                      imageName: self.normalImageNames[0],
                      selectedImageName: self.selectedImageNames[0])
        self.addChild(UIViewController(),
                      title: self.titleNames[1],
                      imageName: self.normalImageNames[1],
                      selectedImageName: self.selectedImageNames[1])
        self.addChild(GXConversationListVC(),
                      title: self.titleNames[2],
                      imageName: self.normalImageNames[2],
                      selectedImageName: self.selectedImageNames[2])
        self.addChild(GXMinePtVC(),
                      title: self.titleNames[3],
                      imageName: self.normalImageNames[3],
                      selectedImageName: self.selectedImageNames[3])

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

    public func showPublishPopover() {
        if !self.isShowPopover {
            self.isShowPopover = true
            let left = self.tabBar.width / 8 * 3
            let bottom = self.view.height - self.tabBar.frame.height
            let point = CGPoint(x: left, y: bottom)
            self.publishView.frame = self.publishButton.bounds
            self.popover.show(self.publishView, point: point)
        }
    }
    
    func  updateTabbarRedPoint(index: Int = 2) {
        self.redPointView.removeFromSuperview()
        if (GXUserManager.shared.tabRedPointData?.messageRedPoint ?? false) {
            let itemWidth = self.tabBar.width / CGFloat(self.titleNames.count)
            let left = itemWidth * CGFloat(index) + (itemWidth - 24)/2 - 4
            self.redPointView.frame.origin = CGPoint(x: left, y: 28.0)
            self.tabBar.addSubview(self.redPointView)
        }
    }
}

extension GXTabBarPublisherC {
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

    @objc func gotoPublish() {
        self.popover.dismiss()

        guard let navc = self.selectedViewController as? GXBaseNavigationController else { return }
        GXUserManager.gotoPublish(navc: navc)
    }
}

extension GXTabBarPublisherC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[1] {
            self.gotoPublish()
            return false
        }
        else {
            if !GXUserManager.shared.isLogin {
                GXLoginManager.gotoLogin(fromVC: tabBarController)
                return false
            }
        }
        return true
    }
}

extension GXTabBarPublisherC {
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
            let vc = GXChatViewController(messageType: 1, chatId: model.targetId, activityId: model.activityId, title: nil)
            let nav = GXBaseNavigationController(rootViewController: vc)
            self.gx_present(nav, style: .push)
        case 2: /// 发布者端
            let vc = GXPublishReviewVC.createVC(activityId: model.activityId, selectIndex: 1)
            vc.hidesBottomBarWhenPushed = true
            navc.pushViewController(vc, animated: true)
        case 3: /// 参与者端
            break
        case 4: /// 参与者端
            break
        case 5: /// 参与者端
            break
        case 6: /// 参与者端
            break
        case 7: /// 发布者端
            let vc = GXPublishWorkReportVC(activityId: model.activityId)
            vc.hidesBottomBarWhenPushed = true
            navc.pushViewController(vc, animated: true)
        case 8: /// 发布者端
            self.selectedIndex = 0
            if let homeVC = navc.viewControllers.first as? GXPublishHomeVC {
                homeVC.selectedToIndex(index: 0)
            }
        case 9: /// 参与者端
            break
        case 10: /// 发布者端
            let vc = GXPublishActivityDetailVC.createVC(activityId: model.activityId)
            vc.hidesBottomBarWhenPushed = true
            navc.pushViewController(vc, animated: true)
        default: break
        }
        GXUserManager.shared.notificationModel = nil
    }
}
