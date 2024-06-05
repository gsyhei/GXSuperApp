//
//  GXPublishActivityDetailSecCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/14.
//

import UIKit
import Reusable

class GXPublishActivityDetailSecCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = .gx_dingTalkFont(size: 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
