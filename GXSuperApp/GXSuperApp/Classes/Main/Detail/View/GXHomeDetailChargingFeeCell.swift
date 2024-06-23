//
//  GXHomeDetailChargingFeeCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/23.
//

import UIKit
import Reusable

class GXHomeDetailChargingFeeCell: UITableViewCell, NibReusable {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var kWhLabel: UILabel!
    @IBOutlet weak var vipKWhLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
