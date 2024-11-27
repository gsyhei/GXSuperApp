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
    @IBOutlet weak var checkButton: UIButton!

    var removeAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindCell(model: GXStripePaymentListDataItem?) {
        guard let model = model else { return }
        
        self.rightButton.layer.borderWidth = 1.0
        self.rightButton.layer.borderColor = UIColor.gx_red.cgColor
        self.rightButton.setBackgroundColor(.white, for: .normal)
        self.rightButton.setBackgroundColor(.gx_background, for: .highlighted)
        
        self.titleLabel.text = "Credit Card"
        self.detailLabel.text = "********" + model.last4
        self.rightButton.setTitle("Remove", for: .normal)
        self.rightButton.setTitleColor(.gx_red, for: .normal)
    }
        
    @IBAction func rightButtonClicked(_ sender: UIButton) {
        self.removeAction?()
    }
}
