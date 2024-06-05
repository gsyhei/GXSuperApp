//
//  UIAlertController+Add.swift
//  QROrderSystem
//
//  Created by Gin on 2021/9/11.
//

import UIKit

extension UIAlertController {
    
    func addColorInTitleAndMessage(color: UIColor = .gx_black, titleFontSize:CGFloat = 18, messageFontSize:CGFloat = 15) {
        let attributesTitle: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: UIFont.boldSystemFont(ofSize: titleFontSize)]
        let attributesMessage: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: UIFont.systemFont(ofSize: messageFontSize)]
        let attributedTitleText = NSAttributedString(string: self.title ?? "", attributes: attributesTitle)
        let attributedMessageText = NSAttributedString(string: self.message ?? "", attributes: attributesMessage)
        self.setValue(attributedTitleText, forKey: "attributedTitle")
        self.setValue(attributedMessageText, forKey: "attributedMessage")
    }
    
}
