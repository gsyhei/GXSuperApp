//
//  GXChargingOrderLRTextCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/7.
//

import UIKit
import Reusable

class GXChargingOrderLRTextCell: UITableViewCell, NibReusable {
    struct Model {
        var leftText: String = ""
        var rightText: String = ""
        var isShowCopy: Bool = false
        var leftColor: UIColor = .gx_drakGray
        var rightColor: UIColor = .gx_textBlack
        init(leftText: String, 
             rightText: String,
             isShowCopy: Bool = false,
             leftColor: UIColor = .gx_drakGray,
             rightColor: UIColor = .gx_textBlack)
        {
            self.leftText = leftText
            self.rightText = rightText
            self.isShowCopy = isShowCopy
            self.leftColor = leftColor
            self.rightColor = rightColor
        }
    }
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var rightLBRightLC: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true        
    }
    
    func bindCell(model: Model) {
        self.leftLabel.textColor = model.leftColor
        self.rightLabel.textColor = model.rightColor
        self.leftLabel.text = model.leftText
        self.rightLabel.text = model.rightText
        self.copyButton.isHidden = !model.isShowCopy
        self.rightLBRightLC.constant = model.isShowCopy ? 26 : 0
    }
    
}

extension GXChargingOrderLRTextCell {
    
    @IBAction func copyOrderIdButtonClicked(_ sender: Any?) {
        UIPasteboard.general.string = self.rightLabel.text
        GXToast.showSuccess(text: "Copied to pasteboard", to: self.superview?.superview)
    }
    
}
