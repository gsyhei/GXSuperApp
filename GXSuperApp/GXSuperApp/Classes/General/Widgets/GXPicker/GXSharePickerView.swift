//
//  GXSharePickerView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/20.
//

import UIKit

class GXSharePickerView: UIView {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var wxsessionButton: UIButton!
    @IBOutlet weak var wxtimelineButton: UIButton!

    var completion: GXActionBlockItem<Int>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.cancelButton.setBackgroundColor(.white, for: .normal)
        self.cancelButton.setBackgroundColor(.gx_lightGray, for: .highlighted)

        self.wxsessionButton.imageLocationAdjust(model: .top, spacing: 3.0)
        self.wxtimelineButton.imageLocationAdjust(model: .top, spacing: 3.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 12.0)
    }
}

extension GXSharePickerView {
    @IBAction func closeButtonClicked(_ sender: Any?) {
        self.hide(animated: true)
    }
    @IBAction func wxsessionButtonClicked(_ sender: Any?) {
        self.hide(animated: true)
        self.completion?(0)
    }
    @IBAction func wxtimelineButtonClicked(_ sender: Any?) {
        self.hide(animated: true)
        self.completion?(1)
    }
}
