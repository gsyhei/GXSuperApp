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
    @IBOutlet weak var leftLineImgView: UIImageView!
    @IBOutlet weak var tagsView: GXTagsView!
    @IBOutlet weak var tagsHeightLC: NSLayoutConstraint!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressDetailLabel: UILabel!
    @IBOutlet weak var bottomImgView: UIImageView!
    @IBOutlet weak var favoritedButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        
        let lineColors: [UIColor] = [.gx_green, UIColor(hexString: "#278CFF")]
        self.leftLineImgView.image = UIImage(gradientColors: lineColors, style: .vertical, size: CGSize(width: 4, height: 14))
        let bottomColors: [UIColor] = [.gx_lightGreen, .white]
        self.bottomImgView.image = UIImage(gradientColors: bottomColors, style: .vertical, size: CGSize(width: 10, height: 40))
        self.tagsView.updateTitles(titles: [], width: SCREEN_WIDTH - 48, isShowFristLine: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.timeView.cornerRadius = self.timeView.frame.height/2
        self.timeView.layer.borderWidth = 0.5
        self.timeView.layer.borderColor = UIColor.gx_lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXStationConsumerDetailData?) {
        guard let model = model else { return }
        
        self.nameLabel.text = model.name
        let titles = model.aroundFacilitiesList.compactMap { $0.name }
        let height = self.tagsView.updateTitles(titles: titles, width: SCREEN_WIDTH - 48, isShowFristLine: false)
        self.tagsHeightLC.constant = height
        self.favoritedButton.isSelected = (model.favoriteFlag == "YES")
        self.addressLabel.text = model.address
        self.addressDetailLabel.text = model.siteGuidance
    }
    
}

extension GXHomeDetailCell1 {
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        
    }
    @IBAction func favoritedButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func navigationButtonClicked(_ sender: UIButton) {
        
    }
}
