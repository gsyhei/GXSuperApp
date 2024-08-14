//
//  GXBaseViewController.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit
import RxSwift

class GXBaseViewController: UIViewController {
    let disposeBag = DisposeBag()
    var didGetNetworktLoad: Bool = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    private lazy var navTopView: UIView = {
        return UIView(frame: CGRect(origin: .zero, size: CGSize(width: SCREEN_HEIGHT, height: 44))).then {
            $0.backgroundColor = .white
        }
    }()

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// 退出当前VC
        if self.isBeingDismissed {
            self.viewDidDisappearPopOrDismissed(animated)
        }
        else if self.isMovingFromParent {
            self.viewDidDisappearPopOrDismissed(animated)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewController()
        
        NotificationCenter.default.rx
            .notification(GX_NotifName_Login)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.loginReloadViewData()
            }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.didGetNetworktLoad {
            self.viewDidAppearForAfterLoading()
        }
        self.didGetNetworktLoad = true
    }
    
    public func viewDidAppearForAfterLoading() {
        
    }
    
    public func setupViewController() {
        fatalError("Must Override.")
    }
    
    public func viewDidDisappearPopOrDismissed(_ animated: Bool) {
        
    }
    
    public func loginReloadViewData() {
        
    }

    public func gx_addNavTopView(color: UIColor) {
        self.navTopView.backgroundColor = color
        self.view.addSubview(self.navTopView)
        self.navTopView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
    }

    public func gx_addBackBarButtonItem(action: Selector = #selector(gx_backBarButtonItemTapped)) {
        let normalImage = UIImage(named: "com_nav_ic_back")?.withRenderingMode(.automatic)
        let leftBarButtonItem = UIBarButtonItem(image: normalImage, style: .plain, target: self, action: action)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    @objc public func gx_backBarButtonItemTapped() {
        if (self.navigationController?.popViewController(animated: true) == nil) {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
