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
    
    func updateNumber(usNumber: Int, tslNumber: Int) {
        /// TSL
        let tslAttributedString = NSMutableAttributedString()
        let tslNumberText = String(format: "%d", usNumber)
        let tslNumAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_boldFont(size: 13),
            .foregroundColor: UIColor.gx_drakRed
        ]
        let numberAttributed = NSAttributedString(string: tslNumberText, attributes: tslNumAttributes)
        tslAttributedString.append(numberAttributed)

        let tslMaxNumberText = String(format: "/%d", 20)
        let tslMaxNumAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: 13),
            .foregroundColor: UIColor.gx_drakRed
        ]
        let tslNumberAttributed = NSAttributedString(string: tslMaxNumberText, attributes: tslMaxNumAttributes)
        tslAttributedString.append(tslNumberAttributed)
        self.tslNumberLabel.attributedText = tslAttributedString
        let tslWidth = tslAttributedString.width()
        
        /// US
        let usAttributedString = NSMutableAttributedString()
        let usNumberText = String(format: "%d", usNumber)
        let usNumAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_boldFont(size: 13),
            .foregroundColor: UIColor.gx_blue
        ]
        let usNumberAttributed = NSAttributedString(string: usNumberText, attributes: usNumAttributes)
        usAttributedString.append(usNumberAttributed)
        
        let usMaxNumberText = String(format: "/%d", 20)
        let usMaxNumAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: 13),
            .foregroundColor: UIColor.gx_blue
        ]
        let usMaxNumberAttributed = NSAttributedString(string: usMaxNumberText, attributes: usMaxNumAttributes)
        usAttributedString.append(usMaxNumberAttributed)
        self.usNumberLabel.attributedText = usAttributedString
        let usWidth = usAttributedString.width()
        
        let width = max(usWidth, tslWidth)
        self.frame.size.width = width + 58
    }
    
    func updateStatus(isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .gx_green
            self.layer.borderWidth = 0.0
            self.layer.borderColor = nil
            
            self.usNumberBgView.backgroundColor = .gx_drakGreen
            self.tslNumberBgView.backgroundColor = .gx_drakGreen
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_selected")
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_selected")
            self.usNumberLabel.textColor = .white
            self.tslNumberLabel.textColor = .white
        }
        else {
            self.backgroundColor = .white
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.gx_lightGray.cgColor
            
            self.usNumberBgView.backgroundColor = .gx_lightBlue
            self.tslNumberBgView.backgroundColor = .gx_lightRed
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_normal")
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_normal")
            self.usNumberLabel.textColor = .gx_blue
            self.tslNumberLabel.textColor = .gx_drakRed
        }
    }
}
