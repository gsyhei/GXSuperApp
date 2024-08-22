//
//  GXHomeDetailCell8.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/22.
//

import UIKit
import Reusable

class GXHomeDetailCell8: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var advertTitleLabel: UILabel!
    @IBOutlet weak var advertInfoLabel: UILabel!
    @IBOutlet weak var advertKWhLabel: UILabel!
    var vipAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func bindCell() {
        if GXUserManager.shared.isVip {
            self.advertTitleLabel.text = "VIP for Discounts"
        }
        else {
            self.advertTitleLabel.text = "Become a VIP for Discounts"
        }
        self.advertInfoLabel.text = (GXUserManager.shared.paramsData?.memberReduction ?? "")
        self.advertKWhLabel.text = "$\(GXUserManager.shared.paramsData?.memberFee ?? "")"
    }
    
    @IBAction func advertButtonClicked(_ sender: Any?) {
        self.vipAction?()
    }
}
