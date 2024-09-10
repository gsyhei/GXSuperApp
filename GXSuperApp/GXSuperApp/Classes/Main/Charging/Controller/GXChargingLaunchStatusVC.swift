//
//  GXChargingLaunchStatusVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/6.
//

import UIKit
import MBProgressHUD
import PromiseKit
import XCGLogger

class GXChargingLaunchStatusVC: GXBaseViewController {
    @IBOutlet weak var failedView: UIView!
    @IBOutlet weak var failedLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var chargingGunView: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    private var displayLink: CADisplayLink?
    private var progressCount: Int = 0
    weak var viewModel: GXChargingFeeConfirmViewModel!
    
    class func createVC(viewModel: GXChargingFeeConfirmViewModel) -> GXChargingLaunchStatusVC {
        return GXChargingLaunchStatusVC.xibViewController().then {
            $0.viewModel = viewModel
        }
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestOrderConsumerStart()
    }
    
    override func setupViewController() {
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
    }
    
    func setChargingStatus(isLoading: Bool, isStop: Bool, errorInfo: String? = nil) {
        if isLoading {
            self.navigationItem.title = nil
            self.loadingView.isHidden = false
            self.navTopView.isHidden = true
            self.failedView.isHidden = true
            if isStop {
                self.stopLoopCircleAnimation()
                self.stopAnimation()
                self.progressLabel.text = "100%"
            }
            else {
                self.startLoopCircleAnimation()
                self.startAnimation()
            }
        }
        else {
            self.navigationItem.title = "Launch Failed"
            self.loadingView.isHidden = true
            self.navTopView.isHidden = false
            self.failedView.isHidden = false
            if let errorInfo = errorInfo {
                self.failedLabel.text = errorInfo
            }
            if isStop {
                self.stopLoopCircleAnimation()
                self.stopAnimation()
            }
        }
    }
}

extension GXChargingLaunchStatusVC {
    func requestOrderConsumerStart() {
        self.setChargingStatus(isLoading: true, isStop: false)
        firstly {
            self.viewModel.requestOrderConsumerStart()
        }.done { model in
            self.updateChargingStatusNext()
        }.catch { error in
            self.setChargingStatus(isLoading: false, isStop: true, errorInfo: error.localizedDescription)
        }
    }
    @objc func updateChargingStatusNext() {
        firstly {
            self.viewModel.requestChargingConsumerStatus()
        }.done { model in
            if model.data?.status == .CHARGING {
                self.pushChargingCarShowVC()
            } 
            else if model.data?.status == .START_FAILED {
                let errInfo = "Please reinsert the charging gun and scan the code again"
                self.setChargingStatus(isLoading: false, isStop: true, errorInfo: errInfo)
            }
            else {
                self.perform(#selector(self.updateChargingStatusNext), with: nil, afterDelay: 2)
            }
        }.catch { error in
            self.perform(#selector(self.updateChargingStatusNext), with: nil, afterDelay: 2)
        }
    }
    func pushChargingCarShowVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setChargingStatus(isLoading: true, isStop: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let vc = GXChargingCarShowVC.createVC(orderId: self.viewModel.orderId)
                self.navigationController?.pushByReturnToViewController(vc: vc, animated: false)
                UIView.transition(.promise, from: self.view, to: vc.view, duration: 1.0, options: .transitionCrossDissolve)
            }
        }
    }
}

extension GXChargingLaunchStatusVC {
    func stopAnimation() {
        self.displayLink?.invalidate()
        self.displayLink = nil
        self.progressCount = 0
    }
    func startAnimation() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
        self.displayLink?.add(to: .current, forMode: .common)
        self.displayLink?.preferredFramesPerSecond = 60
    }
    @objc func handleDisplayLink(displayLink: CADisplayLink) {
        self.progressCount += 1
        // 每秒进度 (60 / 6) = 10%
        var progress = self.progressCount / (60 / 6)
        if progress > 99 { progress = 99 }
        self.progressLabel.text = "\(Int(progress))%"
    }
    func startLoopCircleAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = (Double.pi * 2)
        rotationAnimation.duration = 2.0
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.repeatCount = Float.infinity
        self.circleImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.5
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = 1.0
        opacityAnimation.autoreverses = true
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.repeatCount = Float.infinity
        self.chargingGunView.layer.add(opacityAnimation, forKey: "opacityAnimation")
    }
    func stopLoopCircleAnimation() {
        self.circleImageView.layer.removeAllAnimations()
        self.chargingGunView.layer.removeAllAnimations()
    }
}

extension GXChargingLaunchStatusVC {
    @IBAction func scanButtonClicked(_ sender: Any?) {
        let vc = GXQRCodeReaderVC.xibViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.didFindCodeAction = {[weak self] (model, scanVC) in
            guard let `self` = self else { return }
            let tovc = GXChargingFeeConfirmVC.instantiate()
            tovc.viewModel.scanData = model.data
            self.navigationController?.pushByRootToViewController(vc: tovc, animated: true)
        }
        self.present(vc, animated: true)
    }
}
