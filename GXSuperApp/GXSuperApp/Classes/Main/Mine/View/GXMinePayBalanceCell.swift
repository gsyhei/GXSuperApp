//
//  GXMinePayBalanceCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/15.
//

import UIKit
import Reusable

class GXMinePayBalanceCell: UITableViewCell, NibReusable {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.text = "Balance (Default)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
