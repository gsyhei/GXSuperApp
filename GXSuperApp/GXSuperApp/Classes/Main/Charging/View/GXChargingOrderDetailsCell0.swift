//
//  GXChargingOrderDetailsCell0.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import Reusable

class GXChargingOrderDetailsCell0: UITableViewCell, NibReusable {
    @IBOutlet weak var vehicleContainerView: UIView!
    @IBOutlet weak var vehicleBackIView: UIImageView!
    @IBOutlet weak var vehicleNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        
        let colors: [UIColor] = [.gx_green, .gx_blue]
        self.vehicleBackIView.image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 10, height: 24))
        self.vehicleContainerView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        
        if model.carNumber.isEmpty {
            self.vehicleContainerView.isHidden = true
        }
        else {
            self.vehicleContainerView.isHidden = false
            self.vehicleNumLabel.text = model.carNumber.formatCarNumber
        }
    }
}
