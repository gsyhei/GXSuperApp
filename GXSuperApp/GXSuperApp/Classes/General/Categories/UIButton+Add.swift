//
//  UIButton+Add.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/22.
//

import UIKit

extension UIButton {

    func gx_setDisabledButton() {
        self.setTitleColor(.gx_drakGray, for: .disabled)
        self.setBackgroundColor(.gx_lightGray, for: .disabled)
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
        self.isEnabled = false
    }

    func gx_setGrayButton() {
        self.setTitleColor(.gx_black, for: .normal)
        self.setBackgroundColor(.gx_lightGray, for: .normal)
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
        self.isSelected = false
        self.isEnabled = true
    }

    func gx_setGreenButton() {
        self.setTitleColor(.gx_black, for: .normal)
        self.setBackgroundColor(.gx_green, for: .normal)
        self.layer.masksToBounds = true
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
        self.isSelected = false
        self.isEnabled = true
    }

    func gx_setRedBorderButton() {
        let color = UIColor.gx_red
        self.setTitleColor(color, for: .normal)
        self.setBackgroundColor(.gx_background, for: .normal)
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
        self.isSelected = false
        self.isEnabled = true
    }

    func gx_setBlackButton() {
        self.setTitleColor(.gx_green, for: .normal)
        self.setBackgroundColor(.gx_black, for: .normal)
        self.layer.masksToBounds = true
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
        self.isSelected = false
        self.isEnabled = true
    }

    func gx_setGrayBorderButton() {
        self.setTitleColor(.gx_gray, for: .normal)
        self.setBackgroundColor(.gx_background, for: .normal)
        self.layer.borderColor = UIColor.gx_background.cgColor
        self.layer.borderWidth = 1
        self.isSelected = false
        self.isEnabled = true
    }

    func gx_setSelectedGrayButton() {
        self.setTitleColor(.gx_gray, for: .selected)
        self.setBackgroundColor(.gx_background, for: .selected)
        self.layer.borderColor = UIColor.gx_background.cgColor
        self.layer.borderWidth = 1
        self.isSelected = true
        self.isEnabled = true
    }
    
    func gx_setGreenBorderButton() {
        self.setBackgroundColor(.gx_background, for: .normal)
        let color = UIColor.gx_drakGreen
        self.setTitleColor(color, for: .normal)
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
        self.isSelected = false
        self.isEnabled = true
    }
}
