//
//  GXTabBarController.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/6.
//

import UIKit
import RxSwift
import SnapKit

class GXTabBarController: UITabBarController {
    let disposeBag = DisposeBag()
    private lazy var normalImageNames : [String] = {
        return ["com_tab_ic_home_normal", "com_tab_ic_vip_normal", "", "com_tab_ic_order_normal", "com_tab_ic_me_normal"]
    }()
    private lazy var selectedImageNames : [String] = {
        return ["com_tab_ic_home_selected", "com_tab_ic_vip_selected", "", "com_tab_ic_order_selected", "com_tab_ic_me_selected"]
    }()
    private lazy var titleNames : [String] = {
        return ["Home", "Vip", "", "Order", "Me"]
    }()
    private lazy var qrcodeButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.isUserInteractionEnabled = false
            $0.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
            $0.backgroundColor = .gx_green
            $0.setImage(UIImage(named: "com_tab_ic_scan"), for: .normal)
            $0.layer.cornerRadius = 28.0
            $0.setLayerShadow(color: .green, offset: .zero, radius: 4.0)
            $0.layer.shadowOpacity = 0.5
        }
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.clickNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.delegate = self
        
        self.addChild(GXHomeVC.xibViewController(),
                      title: self.titleNames[0],
                      imageName: self.normalImageNames[0],
                      selectedImageName: self.selectedImageNames[0])
        self.addChild(UIViewController(),
                      title: self.titleNames[1],
                      imageName: self.normalImageNames[1],
                      selectedImageName: self.selectedImageNames[1])
        self.addChild(UIViewController(),
                      title: self.titleNames[2],
                      imageName: self.normalImageNames[2],
                      selectedImageName: self.selectedImageNames[2])
        self.addChild(UIViewController(),
                      title: self.titleNames[3],
                      imageName: self.normalImageNames[3],
                      selectedImageName: self.selectedImageNames[3])
        self.addChild(UIViewController(),
                      title: self.titleNames[4],
                      imageName: self.normalImageNames[4],
                      selectedImageName: self.selectedImageNames[4])
        
        self.tabBar.addSubview(self.qrcodeButton)
        self.tabBar.bringSubviewToFront(self.qrcodeButton)
        self.qrcodeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
        
        NotificationCenter.default.rx
            .notification(GX_NotifName_ClickNotification)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.clickNotification()
            }).disposed(by: disposeBag)
    }
}

extension GXTabBarController {
    private func addChild(_ vc: UIViewController, title: String?, imageName: String?, selectedImageName:String?) {
        let childVC = GXBaseNavigationController(rootViewController: vc)
        childVC.title = title
        if let letImageName = imageName, !letImageName.isEmpty {
            childVC.tabBarItem.image = UIImage(named: letImageName)?.withRenderingMode(.alwaysOriginal)
        }
        else {
            childVC.tabBarItem.image = nil
        }
        if let letSelectedImageName = selectedImageName, !letSelectedImageName.isEmpty {
            childVC.tabBarItem.selectedImage = UIImage(named: letSelectedImageName)?.withRenderingMode(.alwaysOriginal)
        }
        else {
            childVC.tabBarItem.selectedImage = nil
        }
        self.addChild(childVC)
    }
}

extension GXTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[2] {
            // 扫码入口
            return false
        }
        return true
    }
}

private extension GXTabBarController {
    func clickNotification() {
        
    }
}
