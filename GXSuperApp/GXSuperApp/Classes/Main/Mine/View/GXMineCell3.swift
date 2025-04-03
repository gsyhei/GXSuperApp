//
//  GXMineCell3.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import Reusable

class GXMineCell3: UITableViewCell, NibReusable {
    @IBOutlet weak var advertTitleLabel: UILabel!
    @IBOutlet weak var advertInfoLabel: UILabel!
    @IBOutlet weak var renewButton: UIButton!
    var action: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.renewButton.isHidden = true
        self.renewButton.setBackgroundColor(.gx_black, for: .normal)
        self.renewButton.setBackgroundColor(.gx_drakGray, for: .highlighted)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateVipCell(action: GXActionBlock?) {
        self.action = action
        
        var labelTitle: String
        if GXUserManager.shared.isVip {
            self.advertTitleLabel.text = "VIP for Discounts"
            labelTitle = "Renew"
        }
        else {
            self.advertTitleLabel.text = "Become a VIP"
            labelTitle = "Join"
        }
        self.renewButton.setTitle(labelTitle, for: .normal)
        let labelFont = self.renewButton.titleLabel?.font ?? .gx_boldFont(size: 16)
        let labelSize = CGSize(width: labelTitle.width(font: labelFont), height: labelFont.lineHeight)
        let colors: [UIColor] = [UIColor(hexString: "#FFF8B5"), UIColor(hexString: "#CD661D")]
        if let gradientImage = UIImage(gradientColors: colors, style: .horizontal, size: labelSize) {
            let textColor = UIColor(patternImage: gradientImage)
            self.renewButton.setTitleColor(textColor, for: .normal)
        }
        self.advertInfoLabel.text = (GXUserManager.shared.paramsData?.memberReduction ?? "")
    }
    
    @IBAction func renewButtonClicked(_ sender: UIButton) {
        self.action?()
    }
}
