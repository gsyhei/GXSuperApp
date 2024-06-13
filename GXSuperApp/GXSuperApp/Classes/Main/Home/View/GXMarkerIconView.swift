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
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gx_lightGray.cgColor
    }
}

extension GXMarkerIconView {
    
    func updateNumber(usNumber: String, tslNumber: String) {
        self.usNumberLabel.text = usNumber
        let usWidth = usNumber.width(font: self.usNumberLabel.font)
        
        self.tslNumberLabel.text = tslNumber
        let tslWidth = usNumber.width(font: self.tslNumberLabel.font)
        
        let width = max(usWidth, tslWidth)
        self.frame.size.width = width + 58
    }
    
    func updateStatus(isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .gx_green
            self.usNumberBgView.backgroundColor = .gx_drakGreen
            self.tslNumberBgView.backgroundColor = .gx_drakGreen
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_selected")
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_selected")
            self.usNumberLabel.textColor = .white
            self.tslNumberLabel.textColor = .white
        }
        else {
            self.backgroundColor = .white
            self.usNumberBgView.backgroundColor = .gx_lightBlue
            self.tslNumberBgView.backgroundColor = .gx_lightRed
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_normal")
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_normal")
            self.usNumberLabel.textColor = .gx_blue
            self.tslNumberLabel.textColor = .gx_drakRed
        }
    }
}
