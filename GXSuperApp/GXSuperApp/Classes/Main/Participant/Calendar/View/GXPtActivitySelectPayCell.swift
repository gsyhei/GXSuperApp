//
//  GXPtActivitySelectPayCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import Reusable

class GXPtActivitySelectPayCell: UITableViewCell, NibReusable {
    @IBOutlet weak var payIconIview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark:.none
    }
    
    func bindCell(index: Int) {
        if index == 0 {
            self.payIconIview.image = UIImage(named: "pt_pay_wx")
            self.nameLabel.text = "微信"
        }
        else {
            self.payIconIview.image = UIImage(named: "pt_pay_zfb")
            self.nameLabel.text = "支付宝"
        }
    }
}
