//
//  GXChargingOrderDetailsCell1.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import Reusable
import XCGLogger

class GXChargingOrderDetailsCell1: GXRoundViewCell, NibReusable {
    @IBOutlet weak var vehicleTopLC: NSLayoutConstraint!
    @IBOutlet weak var endChargingBottomLC: NSLayoutConstraint!
    @IBOutlet weak var vehicleContanerView: UIView!
    @IBOutlet weak var occupyingContanerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCell(type: Int) {
        switch type {
        case 0:
            self.vehicleContanerView.isHidden = false
            self.occupyingContanerView.isHidden = false
            self.vehicleTopLC.constant = 74
            self.endChargingBottomLC.constant = 111
        case 1:
            self.vehicleContanerView.isHidden = false
            self.occupyingContanerView.isHidden = true
            self.vehicleTopLC.constant = 8
            self.endChargingBottomLC.constant = 45
        case 2:
            self.vehicleContanerView.isHidden = true
            self.occupyingContanerView.isHidden = true
            self.vehicleTopLC.constant = 12
            self.endChargingBottomLC.constant = 12
        default:break
        }
        self.layoutIfNeeded()
    }
    
}

extension GXChargingOrderDetailsCell1 {
    
    @IBAction func copyOrderIdButtonClicked(_ sender: Any?) {
        
    }
    
}
