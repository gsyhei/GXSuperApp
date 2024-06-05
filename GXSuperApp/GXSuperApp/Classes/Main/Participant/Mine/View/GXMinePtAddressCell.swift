//
//  GXMinePtAddressCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import Reusable

class GXMinePtAddressCell: UITableViewCell, NibReusable {
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLeftLC: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        let view = UIImageView(image: UIImage(named: "a_edit_icon"))
        self.accessoryView = view
    }
    
    func bindCell(model: GXUserAddressPageItem?) {
        guard let model = model else { return }

        if model.defaultAddress == 1 {
            self.defaultLabel.isHidden = false
            self.nameLeftLC.constant = 56.0
        }
        else {
            self.defaultLabel.isHidden = true
            self.nameLeftLC.constant = 16.0
        }
        self.nameLabel.text = model.consigneeName
        self.phoneLabel.text = "+86 " + model.consigneePhone
        self.addressLabel.text = model.consigneeAddress + "\n" + model.detailedHouseNumber
    }
}
