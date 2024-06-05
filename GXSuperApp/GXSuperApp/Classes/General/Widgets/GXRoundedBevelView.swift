//
//  GXRoundedBevelView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/28.
//

import UIKit

class GXRoundedBevelView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)

        let radius = rect.height/2
        context.beginPath()

        var point = CGPoint(x: rect.width, y: rect.height)
        context.move(to: point)

        point = CGPoint(x: 0.0, y: rect.height)
        context.addLine(to: point)

        context.addArc(center: CGPoint(x: radius, y: rect.height), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 270 / 180, clockwise: false)

        point = CGPoint(x: rect.width - radius, y: 0)
        context.addLine(to: point)

        context.addArc(center: CGPoint(x: rect.width - radius, y: radius), radius: radius, startAngle: CGFloat.pi * 270 / 180, endAngle: CGFloat.pi * 360 / 180, clockwise: false)

        point = CGPoint(x: rect.width, y: rect.height)
        context.addLine(to: point)

        context.fillPath()
        context.strokePath()
    }

}
