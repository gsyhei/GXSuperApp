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
    @IBOutlet weak var renewLabel: UILabel!
    var action: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let colors: [UIColor] = [UIColor(hexString: "#FFF8B5"), UIColor(hexString: "#E8AA63")]
        if let gradientImage = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 64, height: 32)) {
            self.renewLabel.textColor = UIColor(patternImage: gradientImage)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateVipCell(action: GXActionBlock?) {
        self.action = action
        if GXUserManager.shared.isVip {
            self.advertTitleLabel.text = "VIP for Discounts"
            self.renewLabel.text = "Renew"
        } else {
            self.advertTitleLabel.text = "Become a VIP"
            self.renewLabel.text = "Join"
        }
        self.advertInfoLabel.text = "Save up to $\(GXUserManager.shared.paramsData?.occupyMax ?? "")/year"
    }
    
    @IBAction func renewButtonClicked(_ sender: UIButton) {
        self.action?()
    }
}
