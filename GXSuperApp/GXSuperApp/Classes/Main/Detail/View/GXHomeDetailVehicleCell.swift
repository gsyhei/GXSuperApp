//
//  GXHomeDetailVehicleCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/29.
//

import UIKit
import Reusable

class GXHomeDetailVehicleCell: UITableViewCell, NibReusable {
    @IBOutlet weak var leftLineIView: UIImageView!
    @IBOutlet weak var rightLineIView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        self.numberLabel.skeletonTextLineHeight = .fixed(24)
        
        let colors: [UIColor] = [.gx_green, .gx_blue]
        self.leftLineIView.image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 14, height: 3))
        self.rightLineIView.image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 14, height: 3))
    }
    
}
