//
//  GXHomeMarkerCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/8.
//

import UIKit
import Reusable

class GXHomeMarkerCell: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var topTagsView: GXTagsView!
    @IBOutlet weak var bottomTagsView: GXTagsView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var usNumberBgView: UIView!
    @IBOutlet weak var tslNumberBgView: UIView!
    @IBOutlet weak var usNumberImgView: UIImageView!
    @IBOutlet weak var tslNumberImgView: UIImageView!
    @IBOutlet weak var usNumberLabel: UILabel!
    @IBOutlet weak var tslNumberLabel: UILabel!
    
    private var highlightedEnable: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.topTagsView.updateTitles(titles: ["Convenience store", "Toilet"], width: SCREEN_WIDTH - 48, isShowFristLine: false)
        self.bottomTagsView.updateTitles(titles: ["Parking discount", "Idle fee $0.17 / min"], width: SCREEN_WIDTH - 60, isShowFristLine: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.leftLineView.setRoundedCorners([.topRight, .bottomRight], radius: 2.0)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard self.highlightedEnable else { return }
        self.containerView.backgroundColor = highlighted ? .gx_lightGray : .white
    }
    
}
