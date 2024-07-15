//
//  GXMinePayManagerCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import Reusable

class GXMinePayManagerCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    var action: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindCell(isActivate: Bool) {
        if isActivate {
            self.rightButton.layer.borderWidth = 1.0
            self.rightButton.layer.borderColor = UIColor.gx_green.cgColor
            self.rightButton.setBackgroundColor(.white, for: .normal)
            self.rightButton.setBackgroundColor(.gx_background, for: .highlighted)
            
            self.titleLabel.text = "Credit Card"
            let cardNumber = "2542123125421"
            let count = cardNumber.count
            if count > 8 {
                let beginText = cardNumber.substring(to: 4)
                let endText = cardNumber.substring(from: count - 4)
                var starText: String = ""
                for _ in 0..<(count - 8) { starText.append("*") }
                self.detailLabel.text = beginText + starText + endText
            } else {
                self.detailLabel.text = "********"
            }
            self.rightButton.setTitle("Cancel", for: .normal)
            self.rightButton.setTitleColor(.gx_green, for: .normal)
        }
        else {
            self.rightButton.layer.borderWidth = 0
            self.rightButton.layer.borderColor = nil
            self.rightButton.setBackgroundColor(.gx_green, for: .normal)
            self.rightButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
            
            self.titleLabel.text = "Credit Card Authorization"
            self.detailLabel.text = "Automatic deduction after order completion"
            self.rightButton.setTitle("Activate", for: .normal)
            self.rightButton.setTitleColor(.white, for: .normal)
        }
    }
        
    @IBAction func rightButtonClicked(_ sender: UIButton) {
        self.action?()
    }
}
