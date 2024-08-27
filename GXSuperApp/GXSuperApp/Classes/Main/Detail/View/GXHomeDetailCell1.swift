//
//  GXHomeDetailCell1.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/22.
//

import UIKit
import Reusable

class GXHomeDetailCell1: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var leftLineImgView: UIImageView!
    @IBOutlet weak var tagsView: GXTagsView!
    @IBOutlet weak var tagsHeightLC: NSLayoutConstraint!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressDetailLabel: UILabel!
    var navigationAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        
        let lineColors: [UIColor] = [.gx_green, UIColor(hexString: "#278CFF")]
        self.leftLineImgView.image = UIImage(gradientColors: lineColors, style: .vertical, size: CGSize(width: 4, height: 14))
        self.tagsView.updateTitles(titles: [], width: SCREEN_WIDTH - 48, isShowFristLine: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXStationConsumerDetailData?, distance: Int) {
        guard let model = model else { return }
        
        self.nameLabel.text = model.name
        let distance: Float = Float(distance)/1609.344
        self.distanceLabel.text = String(format: "%.1fmiles", distance)
        let titles = model.aroundFacilitiesList.compactMap { $0.name }
        let height = self.tagsView.updateTitles(titles: titles, width: SCREEN_WIDTH - 48, isShowFristLine: false)
        self.tagsHeightLC.constant = height
        self.addressLabel.text = model.address
        self.addressDetailLabel.text = model.siteGuidance
    }
    
}

extension GXHomeDetailCell1 {
    @IBAction func navigationButtonClicked(_ sender: UIButton) {
        self.navigationAction?()
    }
}
