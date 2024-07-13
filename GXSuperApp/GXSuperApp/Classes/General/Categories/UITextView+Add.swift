//
//  UITextView+Add.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit

extension  UITextView  {

    func gx_setMarginZero() {
        //内容缩进为0（去除左右边距）
        self.textContainer.lineFragmentPadding = 0
        //文本边距设为0（去除上下边距）
        self.textContainerInset = .zero
    }
    
    /// 添加链接文本（链接为空时则表示普通文本）
    func gx_appendLink(string: String, color: UIColor? = nil, urlString: String? = nil) {
        // 原来的文本内容
        let attrString: NSMutableAttributedString = NSMutableAttributedString()
        attrString.append(self.attributedText)
        // 新增的文本内容（使用默认设置的字体样式）
        let attrs: [NSAttributedString.Key: Any] = [
            .font: self.font ?? UIFont.gx_font(size: 15),
            .foregroundColor: self.textColor ?? UIColor.gx_drakGray,
        ]
        let appendString = NSMutableAttributedString(string: string, attributes:attrs)
        // 判断是否是链接文字
        if let url = urlString {
            let range: NSRange = NSMakeRange(0, appendString.length)
            appendString.beginEditing()
            appendString.addAttribute(.link, value: url, range: range)
            appendString.endEditing()
        }
        if let strColor = color {
            self.linkTextAttributes = [.foregroundColor: strColor]
        }     
        // 合并新的文本
        attrString.append(appendString)
        // 设置合并后的文本
        self.attributedText = attrString
    }
}
