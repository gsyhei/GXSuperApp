//
//  UITextField+Add.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit

extension UITextField {
    
    func gx_setPlaceholder(text: String? = nil, color: UIColor? = nil, font: UIFont? = nil) {
        guard text != nil || self.placeholder != nil else { return }
        
        let string = (text != nil) ? text : self.placeholder
        var attributes: [NSAttributedString.Key : Any] = [:]
        if let placeholderColor = color {
            attributes[.foregroundColor] = placeholderColor
        }
        if let placeholderFont = font {
            attributes[.font] = placeholderFont
        }
        let attriStr = NSAttributedString(string: string!, attributes: attributes)
        self.attributedPlaceholder = attriStr
    }
}
