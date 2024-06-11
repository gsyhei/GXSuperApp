//
//  GXRoundedInView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/11.
//

import UIKit

class GXRoundedInView: UIView {
    private let radius: CGFloat = 20.0
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 创建一个非圆角矩形的路径
        let width = SCREEN_MIN_WIDTH * 0.7
        let top = (SCREEN_HEIGHT - width) / 2
        let left = (SCREEN_WIDTH - width) / 2
        let boundRect = CGRect(x: left, y: top, width: width, height:width)
        let rectPath = UIBezierPath(rect: rect)
        rectPath.append(UIBezierPath(roundedRect: boundRect, cornerRadius: self.radius))
        
        // 剪裁上下文到非圆角矩形的路径
        context.addPath(rectPath.cgPath)
        context.clip(using: .evenOdd)
        
        // 在剪裁后的空间里绘制颜色
        let color = UIColor(white: 0.0, alpha: 0.7)
        context.setFillColor(color.cgColor)
        context.fill(rect)
        context.strokePath()
    }
    
}
