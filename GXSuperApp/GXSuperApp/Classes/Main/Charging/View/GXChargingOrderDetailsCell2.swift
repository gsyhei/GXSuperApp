//
//  GXChargingOrderDetailsCell2.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/7.
//

import UIKit
import Reusable

class GXChargingOrderDetailsCell2: UITableViewCell, NibReusable {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    private weak var model: GXChargingOrderDetailData?
    private var feeQueryAction: GXActionBlockItem<GXChargingOrderDetailData?>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXChargingOrderDetailData?, feeQueryAction: GXActionBlockItem<GXChargingOrderDetailData?>?) {
        guard let model = model else { return }
        
        self.model = model
        self.feeQueryAction = feeQueryAction
        self.leftLabel.text = "Charging Fee (\(model.meterTotal)kWh)"
        let meterFree = model.powerFee + model.serviceFee
        self.rightLabel.text = String(format: "$%.2f", meterFree)
    }
}

extension GXChargingOrderDetailsCell2 {
    @IBAction func feeQueryButtonClicked(_ sender: Any?) {
        self.feeQueryAction?(self.model)
    }
}
