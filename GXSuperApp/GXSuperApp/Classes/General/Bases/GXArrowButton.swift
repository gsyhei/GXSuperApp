//
//  GXArrowButton.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit

class GXArrowButton: UIButton {
    override var isSelected: Bool {
        didSet {
            self.setArrowRotation(selected: isSelected)
        }
    }

    func setArrowRotation(selected: Bool) {
        if (selected) {
//            UIView.animate(withDuration: 0.3) {
                self.imageView?.transform = .init(rotationAngle: CGFloat.pi)
//            }
        } else {
//            UIView.animate(withDuration: 0.3) {
                self.imageView?.transform = .identity;
//            }
        }
    }

}
