//
//  GXPrHomeSearchHotCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import Reusable

class GXPrHomeSearchHotCell: UITableViewCell, NibReusable {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(title: String, index: Int) {
        self.titleLabel.text = title
        self.numberLabel.text = "\(index + 1)"
        if index == 0 {
            self.numberLabel.textColor = .gx_pink
        }
        else if index < 3 {
            self.numberLabel.textColor = .gx_yellow
        }
        else {
            self.numberLabel.textColor = .gx_black
        }
    }
}
