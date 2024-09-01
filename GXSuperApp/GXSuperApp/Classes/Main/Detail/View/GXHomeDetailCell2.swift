//
//  GXHomeDetailCell2.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/23.
//

import UIKit
import Reusable

class GXHomeDetailCell2: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usNumberBgView: UIView!
    @IBOutlet weak var tslNumberBgView: UIView!
    @IBOutlet weak var usNumberImgView: UIImageView!
    @IBOutlet weak var tslNumberImgView: UIImageView!
    @IBOutlet weak var usNumberLabel: UILabel!
    @IBOutlet weak var tslNumberLabel: UILabel!
    @IBOutlet weak var maxPowerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXStationConsumerDetailData?) {
        guard let model = model else { return }
        
        // 充电枪信息
        let isOpened = model.stationStatus == "OPENED"
        if isOpened {
            self.tslNumberBgView.backgroundColor = .gx_lightRed
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_normal")
            self.usNumberBgView.backgroundColor = .gx_lightBlue
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_normal")
        }
        else {
            self.tslNumberBgView.backgroundColor = .gx_background
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_disable")
            self.usNumberBgView.backgroundColor = .gx_background
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_disable")
        }
        let tslAttrText: NSAttributedString = .gx_stationAttrText(type: .tsl, isOpened: isOpened, isSelected: false, count: model.teslaIdleCount, maxCount: model.teslaCount)
        self.tslNumberLabel.attributedText = tslAttrText
        let usAttrText: NSAttributedString = .gx_stationAttrText(type: .us, isOpened: isOpened, isSelected: false, count: model.usIdleCount, maxCount: model.usCount)
        self.usNumberLabel.attributedText = usAttrText
        
        self.maxPowerLabel.text = "\(model.maxPower)KW"
    }
}
