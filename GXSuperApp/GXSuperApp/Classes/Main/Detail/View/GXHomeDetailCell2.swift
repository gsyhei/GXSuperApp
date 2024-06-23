//
//  GXHomeDetailCell2.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/23.
//

import UIKit
import Reusable

class GXHomeDetailCell2: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usNumberBgView: UIView!
    @IBOutlet weak var tslNumberBgView: UIView!
    @IBOutlet weak var usNumberImgView: UIImageView!
    @IBOutlet weak var tslNumberImgView: UIImageView!
    @IBOutlet weak var usNumberLabel: UILabel!
    @IBOutlet weak var tslNumberLabel: UILabel!
    @IBOutlet weak var maxPowerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
