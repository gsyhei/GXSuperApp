//
//  GXTabBar.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/11.
//

import UIKit

class GXTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height += 10.0
        return sizeThatFits
    }
}
