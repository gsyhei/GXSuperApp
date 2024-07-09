//
//  GXChargingOrderDetailsCell7.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/8.
//

import UIKit
import Reusable

class GXChargingOrderDetailsCell7: UITableViewCell, NibReusable {
    @IBOutlet weak var freeParkingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        self.freeParkingLabel.text = model.freeParking
    }
}

