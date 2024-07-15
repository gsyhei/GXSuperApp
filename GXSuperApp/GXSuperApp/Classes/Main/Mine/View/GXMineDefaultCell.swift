//
//  GXMineDefaultCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/13.
//

import UIKit
import Reusable

class GXMineDefaultCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.text = nil
        self.detailLabel.text = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.detailLabel.text = nil
    }
    
}
