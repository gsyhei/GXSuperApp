//
//  GXTagsView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/2/27.
//

import UIKit

class GXTagsView: UIView {
    private let font = UIFont.gx_font(size: 13)
    
    @discardableResult
    func updateTitles(titles: [String], width: CGFloat, numberOfLines: Int = 1, isShowFristLine: Bool = false) -> CGFloat {
        let xSpacing: CGFloat = 19.0, ySpacing: CGFloat = 2.0
        let lineW: CGFloat = 1.0, lineH: CGFloat = 9.0
        let labelH: CGFloat = self.font.pointSize
        var top: CGFloat = 0, left: CGFloat = 0
        
        if isShowFristLine {
            let line = createLineView()
            let lineX = left + (xSpacing - lineW)/2
            let lineY = top + (labelH - lineH)/2
            line.frame = CGRect(x: lineX, y: lineY, width: lineW, height: lineH)
            self.addSubview(line)
            left += xSpacing
        }
        
        var curNumberOfLines: Int = 1
        for index in 0..<titles.count {
            let title = titles[index]
            let titleWidth = title.width(font: font)
            let maxW = left + (titleWidth + xSpacing)
            if maxW > width {
                curNumberOfLines += 1
                guard numberOfLines == 0 || curNumberOfLines <= numberOfLines else { break }
                top += (lineH + ySpacing)
            }
            let label = self.createLabel(title: title)
            label.frame = CGRect(x: left, y: top, width: titleWidth, height: labelH)
            self.addSubview(label)
            left = label.right
            
            guard index < titles.count - 1 else { break }
            
            let line = createLineView()
            let lineX = left + (xSpacing - lineW)/2
            let lineY = top + (labelH - lineH)/2
            line.frame = CGRect(x: lineX, y: lineY, width: lineW, height: lineH)
            self.addSubview(line)
            left += xSpacing
        }
        
        return top + labelH
    }
    
}

private extension GXTagsView {
    func createLineView() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor(hexString: "#CECFD3")
        line.layer.masksToBounds = true
        line.layer.cornerRadius = 0.5
        return line
    }
    func createLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = .gx_drakGray
        label.textAlignment = .center
        label.font = self.font
        return label
    }
}
