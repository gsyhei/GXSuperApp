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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.rechargeButton.setBackgroundColor(.gx_green, for: .normal)
        self.rechargeButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.awakeFromNib()
    }
    
}

extension GXChargingOrderDetailsCell6 {
    @IBAction func rechargeButtonClicked(_ sender: Any?) {
        
    }
}
