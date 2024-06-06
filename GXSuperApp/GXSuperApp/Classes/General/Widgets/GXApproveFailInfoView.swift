//
//  GXApproveFailInfoView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/12.
//

import UIKit

class GXApproveFailInfoView: UIView {
    @IBOutlet weak var textLabel: UILabel!

    func update(to view: UIView, text: String) {
        let width = view.frame.width - 60.0
        let textHeight = text.height(width: width, font: .gx_font(size: 15))
        let height = ceil(textHeight) + 16.0
        self.textLabel.text = text
        let top = view.safeAreaInsets.top
        self.frame = CGRect(x: 0, y: top, width: view.frame.width, height: height)
    }
}
