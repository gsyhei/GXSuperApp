//
//  GXChargingOrderDetailsCell0.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import Reusable

class GXChargingOrderDetailsCell0: GXRoundViewCell, NibReusable {
    @IBOutlet weak var vehicleContainerView: UIView!
    @IBOutlet weak var vehicleBackIView: UIImageView!
    @IBOutlet weak var vehicleNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let colors: [UIColor] = [.gx_green, .gx_blue]
        self.vehicleBackIView.image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 10, height: 24))
        
        // Cell 0
        if let vehicle = GXUserManager.shared.selectedVehicle {
            self.vehicleContainerView.isHidden = false
            self.vehicleNumLabel.text = vehicle.state + "-" + vehicle.carNumber
        }
        else {
            self.vehicleContainerView.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
