//
//  GXHomeDetailChargingFeeCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/23.
//

import UIKit
import Reusable

class GXHomeDetailChargingFeeCell: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var kWhLabel: UILabel!
    @IBOutlet weak var vipKWhLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topView.setRoundedCorners([.topLeft, .topRight, .bottomRight], radius: 3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXStationConsumerDetailPricesItem?) {
        guard let model = model else { return }
        
        self.timeLabel.text = "\(model.periodStart)-\(model.periodEnd)"
        if model.priceType == 0 {
            self.topView.isHidden = true
            self.kWhLabel.font = .gx_regularFont(size: 15)
            self.vipKWhLabel.font = .gx_regularFont(size: 15)
        }
        else {
            self.topView.isHidden = false
            if model.priceType == 2 {
                self.topView.backgroundColor = .gx_green
                self.topLabel.text = "Lowest"
                self.kWhLabel.font = .gx_regularFont(size: 15)
                self.vipKWhLabel.font = .gx_regularFont(size: 15)
            }
            else {
                self.topView.backgroundColor = .gx_blue
                self.topLabel.text = "Current"
                self.kWhLabel.font = .gx_boldFont(size: 18)
                self.vipKWhLabel.font = .gx_boldFont(size: 18)
            }
        }
        if GXUserManager.shared.isLogin {
            let kWhFee = model.electricFee + model.serviceFee
            self.kWhLabel.text = String(format: "%.2f", kWhFee)
            let vipkWhFee = model.electricFee + model.serviceFeeVip
            self.vipKWhLabel.text = String(format: "%.2f", vipkWhFee)
            self.feeLabel.text = String(format: "%.2f", model.occupyFee)
        }
        else {
            self.kWhLabel.text = "*****"
            self.vipKWhLabel.text = "*****"
            self.feeLabel.text = "*****"
        }
    }
    
}
