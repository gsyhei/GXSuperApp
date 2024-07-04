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
    var deleteAction: GXActionBlockItem<GXHomeDetailVehicleCell>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        self.numberLabel.skeletonTextLineHeight = .fixed(24)
        
        self.selectionStyle = .default
        let colors: [UIColor] = [.gx_green, .gx_blue]
        self.leftLineIView.image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 14, height: 3))
        self.rightLineIView.image = UIImage(gradientColors: colors, style: .horizontal, size: CGSize(width: 14, height: 3))
    }
    
    func bindCell(model: GXVehicleConsumerListItem?) {
        guard let model = model else { return }
        self.numberLabel.text = model.state + "-" + model.carNumber
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any?) {
        self.deleteAction?(self)
    }
    
}
