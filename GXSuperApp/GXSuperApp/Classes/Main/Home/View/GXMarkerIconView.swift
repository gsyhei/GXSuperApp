//
//  GXMarkerIconView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/8.
//

import UIKit

class GXMarkerIconView: UIView {
    @IBOutlet weak var usNumberBgView: UIView!
    @IBOutlet weak var tslNumberBgView: UIView!
    @IBOutlet weak var usNumberImgView: UIImageView!
    @IBOutlet weak var tslNumberImgView: UIImageView!
    @IBOutlet weak var usNumberLabel: UILabel!
    @IBOutlet weak var tslNumberLabel: UILabel!

    class func createIconView() -> GXMarkerIconView {
        return GXMarkerIconView.xibView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 69, height: 50)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.layer.cornerRadius = 6.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gx_background.cgColor
    }
}

extension GXMarkerIconView {
    
    func bindModel(model: GXStationConsumerRowsModel?, isSelected: Bool) {
        guard let model = model else { return }
        if isSelected {
            self.backgroundColor = .gx_green
            self.layer.borderWidth = 0.0
            self.layer.borderColor = nil
            self.usNumberBgView.backgroundColor = .gx_drakGreen
            self.tslNumberBgView.backgroundColor = .gx_drakGreen
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_selected")
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_selected")
        }
        else {
            self.backgroundColor = .white
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.gx_lightGray.cgColor
            if model.teslaIdleCount == model.teslaCount {
                self.tslNumberBgView.backgroundColor = .gx_background
                self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_disable")
            }
            else {
                self.tslNumberBgView.backgroundColor = .gx_lightRed
                self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_normal")
            }
            if model.usIdleCount == model.usCount {
                self.usNumberBgView.backgroundColor = .gx_background
                self.usNumberImgView.image = UIImage(named: "home_map_ic_us_disable")
            }
            else {
                self.usNumberBgView.backgroundColor = .gx_lightBlue
                self.usNumberImgView.image = UIImage(named: "home_map_ic_us_normal")
            }
        }
        /// TSL
        let tslAttrText: NSAttributedString = .gx_getStationNumAttributedText(type: .tsl, isSelected: isSelected, count: model.teslaIdleCount, maxCount: model.teslaCount)
        self.tslNumberLabel.attributedText = tslAttrText
        let tslWidth = tslAttrText.width()
        
        /// US
        let usAttrText: NSAttributedString = .gx_getStationNumAttributedText(type: .us, isSelected: isSelected, count: model.usIdleCount, maxCount: model.usCount)
        self.usNumberLabel.attributedText = usAttrText
        let usWidth = usAttrText.width()
        
        let width = max(usWidth, tslWidth)
        self.frame.size.width = width + 40
        self.layoutIfNeeded()
    }

}
