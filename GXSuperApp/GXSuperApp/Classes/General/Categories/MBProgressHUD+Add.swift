//
//  MBProgressHUD+Add.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/7/20.
//

import Foundation
import MBProgressHUD

let PROGRESS_HUD_MARGIN: CGFloat      = 12.0
let PROGRESS_HUD_DELAY: TimeInterval  = 2.0

extension UIWindow {
    static var gx_frontWindow: UIWindow? {
        return UIApplication.shared.windows.reversed().first(where: {
            $0.screen == UIScreen.main &&
                !$0.isHidden && $0.alpha > 0 &&
                $0.windowLevel == UIWindow.Level.normal
        })
    }
    class var gx_safeAreaInsets: UIEdgeInsets {
        return gx_frontWindow?.safeAreaInsets ?? .zero
    }
}

extension MBProgressHUD {
    enum Position {
        case top    //头部
        case center //中心
        case bottom //底部
    }
    enum Style {
        case system   //系统菊花圆环 indeterminate
        case circle   //圆环梯度圆环 customView
        case waveBall //小球波浪运动 waveBall
    }
    
    class func showLoading(text: String? = nil, style: Style = .waveBall, ballColor: UIColor = .gx_black, position: Position = .center, to view: UIView? = nil) {
        let hud = MBProgressHUD.showHUD(to: view)
        switch style {
        case .system:
            hud?.mode = .indeterminate
        case .circle:
            hud?.mode = .customView
            let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            hud?.customView = MBProgressHUD.CircleHUDView(frame: frame)
        case .waveBall:
            hud?.bezelView.color = .clear
            hud?.mode = .customView
            let frame = CGRect(x: 0, y: 0, width: 40, height: 20)
            hud?.customView = MBProgressHUD.WaveBallHUDView(frame: frame, ballColor: ballColor)
        }
        hud?.setPosition(position)
        hud?.label.text = text
    }

    class func showContentLoading(text: String? = nil, position: Position = .center, to view: UIView? = nil) {
        let hud = MBProgressHUD.showHUD(to: view)
        hud?.contentColor = .gx_black
        hud?.bezelView.color = .clear
        hud?.setPosition(position)
        hud?.mode = .indeterminate
        hud?.label.text = text
    }
    
    class func showError(_ error: CustomNSError? = nil, position: Position = .center, to view: UIView? = nil) {
        MBProgressHUD.dismiss(for: view)
        guard error?.errorCode != NSURLErrorCancelled else { return }
        guard error?.errorCode != 401 else { return }
        guard error?.errorCode != 6 else { return }
        MBProgressHUD.showError(text: error?.localizedDescription, position: position, to: view)
    }
    
    class func showError(text: String? = nil, position: Position = .center, to view: UIView? = nil) {
        MBProgressHUD.show(text: text, icon: "error.png", position: position, to: view)
    }

    class func showSuccess(text: String? = nil, position: Position = .center, to view: UIView? = nil) {
        MBProgressHUD.show(text: text, icon: "success.png", position: position, to: view)
    }

    class func showInfo(text: String? = nil, position: Position = .center, to view: UIView? = nil) {
        MBProgressHUD.show(text: text, position: position, to: view)
    }

    class func dismiss(for view: UIView? = nil, animated: Bool = true) {
        var tempView = view
        if tempView == nil {
            tempView = UIWindow.gx_frontWindow
        }
        if let toView = tempView {
            MBProgressHUD.hide(for: toView, animated: animated)
        }
    }

    func setPosition(_ position: MBProgressHUD.Position, margin: CGFloat = 10.0) {
        let offsetY: CGFloat = self.bounds.height/2 - self.margin*2 - margin
        switch position {
        case .top:
            self.offset.y -= offsetY
        case .bottom:
            self.offset.y += offsetY
        case .center: break
        }
    }
}

fileprivate extension MBProgressHUD {

    class WaveBallHUDView: UIView {
        required init(frame: CGRect, ballColor: UIColor) {
            super.init(frame: frame)
            self.createSubviews(ballColor: ballColor)
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func createSubviews(ballColor: UIColor) {
            let instanceCount: Int = 3
            let radius: CGFloat = 10.0
            let duration: CGFloat = 0.6
            let instanceSpace: CGFloat = (self.frame.width - radius)/CGFloat(instanceCount-1)

            let replicatorLayer = CAReplicatorLayer()
            replicatorLayer.instanceCount = instanceCount
            replicatorLayer.instanceTransform = CATransform3DMakeTranslation(instanceSpace, 0, 0)
            replicatorLayer.instanceDelay = duration / Double(instanceCount)
            replicatorLayer.instanceColor = UIColor.white.cgColor

            let layer = CALayer()
            layer.position = CGPointMake(radius/2, radius/2)
            layer.anchorPoint = CGPointMake(0.5, 0.5)
            layer.bounds = CGRectMake(0, 0, radius, radius)
            layer.cornerRadius = radius/2
            layer.backgroundColor = ballColor.cgColor
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowRadius = 4.0;
            layer.shadowOffset = CGSizeMake(1.0, 1.0)
            layer.shadowOpacity = 0.5;

            let toValue = self.frame.height - radius
            let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.y")
            animation.fromValue = 0
            animation.toValue = toValue
            animation.duration = duration
            animation.repeatCount = Float.greatestFiniteMagnitude
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.autoreverses = true
            layer.add(animation, forKey: "movey")
            replicatorLayer.addSublayer(layer)
            self.layer.addSublayer(replicatorLayer)
        }
        override var intrinsicContentSize: CGSize {
            return self.frame.size
        }
    }

    class CircleHUDView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.createSubviews()
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func createSubviews() {
            let lineWidth: CGFloat = 3
            let lineMargin: CGFloat = lineWidth / 2
            let arcCenter = CGPoint(x: self.bounds.width / 2 - lineMargin, y: self.bounds.height / 2 - lineMargin)
            let smoothedPath = UIBezierPath(
                arcCenter: arcCenter,
                radius: self.bounds.width / 2 - lineWidth,
                startAngle: 0,
                endAngle: CGFloat(Double.pi * 2),
                clockwise: true
            )
            let layer: CAShapeLayer = {
                $0.contentsScale = UIScreen.main.scale
                $0.frame = CGRect(x: lineMargin, y: lineMargin, width: arcCenter.x * 2, height: arcCenter.y * 2)
                $0.fillColor = UIColor.clear.cgColor
                $0.strokeColor = UIColor.white.cgColor
                $0.lineWidth = 3
                $0.lineCap = CAShapeLayerLineCap.round
                $0.lineJoin = CAShapeLayerLineJoin.bevel
                $0.path = smoothedPath.cgPath
                $0.mask = CALayer()
                $0.mask?.contents = UIImage(named: "MBProgressHUD.bundle/angle-mask.png")?.cgImage
                $0.mask?.frame = $0.bounds
                return $0
            }(CAShapeLayer())
            let animation: CABasicAnimation = {
                $0.fromValue = 0
                $0.toValue = (Double.pi * 2)
                $0.duration = 1
                $0.isRemovedOnCompletion = false
                $0.repeatCount = Float(Int.max)
                $0.autoreverses = false
                return $0
            }(CABasicAnimation(keyPath: "transform.rotation"))
            layer.add(animation, forKey: "rotate")
            self.layer.addSublayer(layer)
        }
        override var intrinsicContentSize: CGSize {
            return self.frame.size
        }
    }
    
    class func showHUD(to view: UIView? = nil) -> MBProgressHUD? {
        var tempView = view
        if tempView == nil {
            tempView = UIWindow.gx_frontWindow
        }
        if let toView = tempView {
            MBProgressHUD.hide(for: toView, animated: false)
            let hud = MBProgressHUD.showAdded(to: toView, animated: true)
            hud.contentColor = .white
            hud.bezelView.style = .solidColor
            hud.bezelView.color = UIColor(white: 0, alpha: 0.8)
            hud.bezelView.layer.cornerRadius = PROGRESS_HUD_MARGIN
            hud.minSize = CGSize(width: 70.0, height: 70.0)
            hud.margin = PROGRESS_HUD_MARGIN
            hud.animationType = .zoom
            hud.removeFromSuperViewOnHide = true
            return hud
        }
        return nil
    }
    
    class func show(text: String? = nil, icon: String? = nil, position: Position, to view: UIView? = nil) {
        let hud = MBProgressHUD.showHUD(to: view)
        if let imageName = icon {
            hud?.mode = .customView
            hud?.customView = UIImageView(image: UIImage(named: "MBProgressHUD.bundle/" + imageName))
        }
        else {
            hud?.mode = .text
        }
        hud?.minSize = .zero
        hud?.detailsLabel.font = .gx_font(size: 16)
        hud?.detailsLabel.text = text
        hud?.hide(animated: true, afterDelay: TimeInterval(PROGRESS_HUD_DELAY))
    }
}
