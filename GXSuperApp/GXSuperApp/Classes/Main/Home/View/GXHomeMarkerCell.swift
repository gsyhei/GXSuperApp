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
    @IBOutlet weak var leftLineImgView: UIImageView!
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
    var highlightedEnable: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .gx_background
        self.selectionStyle = .none
        
        let gradientColors: [UIColor] = [.gx_green, UIColor(hexString: "#278CFF")]
        self.leftLineImgView.image = UIImage(gradientColors: gradientColors, style: .vertical, size: CGSize(width: 4, height: 14))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.leftLineImgView.setRoundedCorners([.topRight, .bottomRight], radius: 2.0)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard self.highlightedEnable else { return }
        self.containerView.backgroundColor = highlighted ? .gx_lightGray : .white
    }
    
    func bindCell(model: GXStationConsumerRowsModel?) {
        guard let model = model else { return }
        
        // 名称
        self.nameLabel.text = model.name
        // 站点服务
        let titles = model.aroundFacilitiesList.compactMap { $0.name }
        self.topTagsView.updateTitles(titles: titles, width: SCREEN_WIDTH - 48, isShowFristLine: false)
        // 电费
        self.priceLabel.text = GXUserManager.shared.isLogin ? "$\(model.electricFee)" : "$*****"
        
        // 充电枪信息
        if model.teslaIdleCount == model.teslaCount {
            self.tslNumberBgView.backgroundColor = .gx_background
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_disable")
        }
        else {
            self.tslNumberBgView.backgroundColor = .gx_lightRed
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_normal")
        }
        if model.usIdleCount == model.usCount {
            self.usNumberBgView.backgroundColor = .gx_background
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_disable")
        }
        else {
            self.usNumberBgView.backgroundColor = .gx_lightBlue
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_normal")
        }
        let tslAttrText: NSAttributedString = .gx_stationAttrText(type: .tsl, isSelected: false, count: model.teslaIdleCount, maxCount: model.teslaCount)
        self.tslNumberLabel.attributedText = tslAttrText
        let usAttrText: NSAttributedString = .gx_stationAttrText(type: .us, isSelected: false, count: model.usIdleCount, maxCount: model.usCount)
        self.usNumberLabel.attributedText = usAttrText
        
        // 停车减免、服务费
        let occupyFeeInfo = "Idle fee $\(model.occupyFee) / min"
        let btmTitles = model.freeParking.count > 0  ? [model.freeParking, occupyFeeInfo] : [occupyFeeInfo]
        self.bottomTagsView.updateTitles(titles: btmTitles, width: SCREEN_WIDTH - 60, isShowFristLine: true)
        // 距离
        let distance: Float = Float(model.distance)/1000.0
        self.distanceLabel.text = String(format: "%.1fkm", distance)
    }
    
    func bindCell(model: GXFavoriteConsumerListItem?) {
        guard let model = model else { return }
        
        // 名称
        self.nameLabel.text = model.name
        // 站点服务
        let titles = model.aroundFacilitiesList.compactMap { $0.name }
        self.topTagsView.updateTitles(titles: titles, width: SCREEN_WIDTH - 48, isShowFristLine: false)
        // 电费
        self.priceLabel.text = GXUserManager.shared.isLogin ? "$\(model.price)" : "$*****"
        
        // 充电枪信息
        if model.teslaIdleCount == model.teslaCount {
            self.tslNumberBgView.backgroundColor = .gx_background
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_disable")
        }
        else {
            self.tslNumberBgView.backgroundColor = .gx_lightRed
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_normal")
        }
        if model.usIdleCount == model.usCount {
            self.usNumberBgView.backgroundColor = .gx_background
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_disable")
        }
        else {
            self.usNumberBgView.backgroundColor = .gx_lightBlue
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_normal")
        }
        let tslAttrText: NSAttributedString = .gx_stationAttrText(type: .tsl, isSelected: false, count: model.teslaIdleCount, maxCount: model.teslaCount)
        self.tslNumberLabel.attributedText = tslAttrText
        let usAttrText: NSAttributedString = .gx_stationAttrText(type: .us, isSelected: false, count: model.usIdleCount, maxCount: model.usCount)
        self.usNumberLabel.attributedText = usAttrText
        
        // 停车减免、服务费
        let occupyFeeInfo = "Idle fee $\(model.occupyFee) / min"
        let btmTitles = model.freeParking.count > 0  ? [model.freeParking, occupyFeeInfo] : [occupyFeeInfo]
        self.bottomTagsView.updateTitles(titles: btmTitles, width: SCREEN_WIDTH - 60, isShowFristLine: true)
        // 距离
        let distance: Float = Float(model.distance)/1000.0
        self.distanceLabel.text = String(format: "%.1fkm", distance)
    }
    
}
