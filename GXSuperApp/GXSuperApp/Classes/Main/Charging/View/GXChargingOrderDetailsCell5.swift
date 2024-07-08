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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

}

extension GXChargingOrderDetailsCell5 {
    @IBAction func feeQueryButtonClicked(_ sender: Any?) {
        
    }
}
