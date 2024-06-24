//
//  GXCircleProgressBar.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit

class GXCircleProgressBar: UIView {
    private let progressLayer = CAShapeLayer()
    private var progress: CGFloat = 0.0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }
    
    required init(frame: CGRect, lineWidth: CGFloat) {
        super.init(frame: frame)
        setupProgressLayer(lineWidth: lineWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupProgressLayer(lineWidth: CGFloat) {
        layer.addSublayer(progressLayer)
        progressLayer.strokeColor = UIColor.gx_blue.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0),
                                                  radius: (frame.width - lineWidth) / 2.0,
                                                  startAngle: -CGFloat.pi / 2,
                                                  endAngle: CGFloat.pi * 3 / 2,
                                                  clockwise: true).cgPath
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
    }
    
    func setProgressColor(strokeColor: UIColor, fillColor: UIColor = .clear) {
        progressLayer.strokeColor = strokeColor.cgColor
        progressLayer.fillColor = fillColor.cgColor
    }
 
    func setProgress(to newProgress: CGFloat, animated: Bool) {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.fromValue = progress
        animation.toValue = newProgress
        animation.duration = animated ? 0.3 : 0.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        progressLayer.add(animation, forKey: "progressAnimation")
        progress = newProgress
    }
}
     

