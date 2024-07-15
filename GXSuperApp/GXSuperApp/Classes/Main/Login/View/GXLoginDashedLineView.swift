//
//  GXLoginDashedLineView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/15.
//

import UIKit

class GXLoginDashedLineView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineCap(.round)
        context.setLineDash(phase: 0, lengths: [8, 8])
        context.setStrokeColor(UIColor.gx_background.cgColor)
        context.setLineWidth(2.0)
        
        let margin: CGFloat = 30
        let centerWidth: CGFloat = 60
        let width = (rect.size.width - centerWidth)/2 - margin
        let path1 = CGMutablePath()
        path1.move(to: CGPoint(x: width + margin, y: 14))
        path1.addLine(to: CGPoint(x: margin, y: 14))
        context.addPath(path1)

        let path2 = CGMutablePath()
        path2.move(to: CGPoint(x: margin + width + centerWidth, y: 14))
        path2.addLine(to: CGPoint(x: rect.size.width - margin, y: 14))
        context.addPath(path2)

        context.strokePath()
    }
    
}
