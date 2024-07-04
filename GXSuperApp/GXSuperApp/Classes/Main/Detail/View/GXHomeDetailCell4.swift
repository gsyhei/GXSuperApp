//
//  GXHomeDetailCell4.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit
import Reusable

class GXHomeDetailCell4: UITableViewCell, NibReusable {
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var freeParkingLabel: UILabel!
    @IBOutlet weak var vehicleContainerView: UIView!
    @IBOutlet weak var vehicleBackIView: UIImageView!
    @IBOutlet weak var vehicleNumLabel: UILabel!

    var addAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        let colors: [UIColor] = [.gx_green, .gx_blue]
        self.vehicleBackIView.image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 10, height: 24))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addButtonClicked(_ sender: Any?) {
        self.addAction?()
    }
    
    func bindCell(model: GXStationConsumerDetailData?, vehicle: GXVehicleConsumerListItem?) {
        guard let model = model else { return }
        self.freeParkingLabel.text = model.freeParking
        
        if let vehicle = vehicle {
            self.vehicleContainerView.isHidden = false
            self.vehicleNumLabel.text = vehicle.state + "-" + vehicle.carNumber
            self.rightButton.setImage(UIImage(named: "com_list_ic_arrow"), for: .normal)
        }
        else {
            self.vehicleContainerView.isHidden = true
            self.rightButton.setImage(UIImage(named: "details_list_ic_addcar"), for: .normal)
        }
    }
}
