//
//  GXChargingOrderLRTextCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/7.
//

import UIKit
import Reusable

class GXChargingOrderLRTextCell: UITableViewCell, NibReusable {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var rightLBRightLC: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true        
    }
    
    func bindCell(
        leftText: String,
        rightText: String,
        isShowCopy: Bool = false,
        leftColor: UIColor = .gx_drakGray,
        rightColor: UIColor = .gx_textBlack
    ) {
        self.leftLabel.textColor = leftColor
        self.rightLabel.textColor = rightColor
        self.leftLabel.text = leftText
        self.rightLabel.text = rightText
        self.copyButton.isHidden = !isShowCopy
        self.rightLBRightLC.constant = isShowCopy ? 26 : 0
    }
    
}

extension GXChargingOrderLRTextCell {
    
    @IBAction func copyOrderIdButtonClicked(_ sender: Any?) {
        UIPasteboard.general.string = self.rightLabel.text
        GXToast.showSuccess(text: "Copied to pasteboard", to: self.superview?.superview)
    }
    
}
