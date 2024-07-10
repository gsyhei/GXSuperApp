//
//  GXChargingCarShowVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/10.
//

import UIKit

class GXChargingCarShowVC: GXBaseViewController {
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var chargedTimeLabel: UILabel!
    @IBOutlet weak var chargedKwhLabel: UILabel!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBarIView: UIImageView!
    @IBOutlet weak var progressBarRightLC: NSLayoutConstraint!
    
    private var displayLink: CADisplayLink?
    private var progressConstant: CGFloat = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        let colors: [UIColor] = [.gx_green, .init(hexString: "#278CFF")]
        let imageSize = CGSize(width: 10, height: 40.0)
        self.progressBarIView.image = UIImage(gradientColors: colors, style: .horizontal, size: imageSize)
        self.progressBarRightLC.constant = self.progressBarView.width - 80
        self.progressLabel.text = "0%"
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 触发更新约束的函数
        updateBarProgress(to: 1.0) // 将视图的宽度更新为200点，并应用动画
    }
    
}

extension GXChargingCarShowVC {
    
    func updateBarProgress(to progress: CGFloat) {
        let maxWith: CGFloat = progressBarView.width - 80.0
        let constant = maxWith - maxWith * progress
        self.progressConstant = constant
//        self.progressBarRightLC.constant = constant
//        UIView.animate(withDuration: 5) {
//            self.view.layoutIfNeeded()
//        }
        self.startAnimation()
    }
    
    func startAnimation() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
        self.displayLink?.add(to: .current, forMode: .common)
        self.displayLink?.preferredFramesPerSecond = 60
    }
    
    @objc func handleDisplayLink(displayLink: CADisplayLink) {
        let maxWith: CGFloat = progressBarView.width - 80.0
        let progress = 1.0 - self.progressBarRightLC.constant / maxWith
        let progressInt = Int(ceil(progress * 100.0))
        self.progressLabel.text = "\(progressInt)%"

        let speed: CGFloat = self.progressBarRightLC.constant > self.progressConstant ? -2 : 2
        if abs(self.progressBarRightLC.constant - self.progressConstant) > abs(speed) {
            self.progressBarRightLC.constant += speed
        } else {
            self.stopAnimation()
        }
    }
    
    func stopAnimation() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
}
