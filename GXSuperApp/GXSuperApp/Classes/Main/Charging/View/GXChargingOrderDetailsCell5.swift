//
//  GXChargingOrderDetailsCell5.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/7.
//

import UIKit
import Reusable

class GXChargingOrderDetailsCell5: UITableViewCell, NibReusable {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var feeQueryButton: UIButton!
    private var feeQueryAction: GXActionBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    func bindCell5(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        
        self.feeQueryButton.isHidden = true
        self.rightLabel.textColor = .gx_green
        self.leftLabel.text = "Due Amount"
        self.rightLabel.text = "$\(model.totalFee)"
    }
    
    func bindCell9(model: GXChargingOrderDetailData?, feeQueryAction: GXActionBlock?) {
        guard let model = model else { return }
        self.feeQueryAction = feeQueryAction
        self.feeQueryButton.isHidden = false
        self.rightLabel.textColor = .gx_orange
        self.leftLabel.text = "Total"
        self.rightLabel.text = "$\(model.occupyFee)"
    }
}

extension GXChargingOrderDetailsCell5 {
    @IBAction func feeQueryButtonClicked(_ sender: Any?) {
        self.feeQueryAction?()
    }
}
