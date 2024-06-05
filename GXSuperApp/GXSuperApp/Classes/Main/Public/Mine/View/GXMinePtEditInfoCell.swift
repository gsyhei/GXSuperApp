//
//  GXMinePtEditInfoCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/8.
//

import UIKit
import Reusable

class GXMinePtEditInfoCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoLabel.text = "编辑个人介绍"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.infoLabel.preferredMaxLayoutWidth = self.infoLabel.frame.width
    }

}
