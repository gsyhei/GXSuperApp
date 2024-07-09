//
//  GXChargingOrderDetailsCell6.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/7.
//

import UIKit
import Reusable

class GXChargingOrderDetailsCell6: UITableViewCell, NibReusable {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var rechargeButton: UIButton!
    var rechargeAction: GXActionBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        self.rechargeButton.setBackgroundColor(.gx_green, for: .normal)
        self.rechargeButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
    }
    
    func bindCell(model: GXWalletConsumerBalanceData?) {
        guard let model = model else { return }
        self.rightLabel.text = String(format: "$%.2f", model.available)
    }
}

extension GXChargingOrderDetailsCell6 {
    @IBAction func rechargeButtonClicked(_ sender: Any?) {
        self.rechargeAction?()
    }
}
