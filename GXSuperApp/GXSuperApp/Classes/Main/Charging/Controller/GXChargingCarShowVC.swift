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
    private var maxProgressConstant: CGFloat {
        return SCREEN_WIDTH - 110.0
    }
    private var currentProgress: Int {
        let progress = 1.0 - self.progressBarRightLC.constant / self.maxProgressConstant
        return Int(ceil(progress * 100.0))
    }
    
    deinit {
        self.stopAnimation()
    }

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
        self.progressLabel.text = "0%"
        self.view.layoutSubviews()
        self.progressBarRightLC.constant = self.maxProgressConstant
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if abs(self.progressBarRightLC.constant - self.maxProgressConstant) <= 2 {
            self.updateBarProgress(to: 1.0)
        }
        else {
            self.updateBarProgress(to: 0.0)
        }
    }
    
}

extension GXChargingCarShowVC {
    func updateBarProgress(to progress: CGFloat) {
        let maxWith = self.maxProgressConstant
        let constant = maxWith - maxWith * progress
        self.progressConstant = constant
        self.startAnimation()
    }
    func stopAnimation() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    func startAnimation() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
        self.displayLink?.add(to: .current, forMode: .common)
        self.displayLink?.preferredFramesPerSecond = 60
    }
    @objc func handleDisplayLink(displayLink: CADisplayLink) {
        self.progressLabel.text = "\(self.currentProgress)%"
        let speed: CGFloat = self.progressBarRightLC.constant >= self.progressConstant ? -2 : 2
        if abs(self.progressBarRightLC.constant - self.progressConstant) > abs(speed) {
            self.progressBarRightLC.constant += speed
        } else {
            self.stopAnimation()
        }
    }
}
