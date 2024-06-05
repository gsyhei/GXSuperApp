//
//  GXPublishActivityDetailCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/13.
//

import UIKit
import Reusable
import GXBanner
import HXPhotoPicker

class GXPublishActivityDetailCell: UITableViewCell, NibReusable {

    @IBOutlet weak var activityConView: UIView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var signedFavoriteNumLabel: UILabel!
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var activityAddressLabel: UILabel!
    @IBOutlet weak var activityAddressDescLabel: UILabel!
    @IBOutlet weak var activitLimitLabel: UILabel!
    @IBOutlet weak var normalPriceLabel: UILabel!
    @IBOutlet weak var vipPriceLabel: UILabel!
    @IBOutlet weak var activityTicketTypeIView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cdMapButton: UIButton!
    @IBOutlet weak var cdMapLabel: UILabel!

    var locationAction: GXActionBlock?
    var cdmapAction: GXActionBlock?
    var ruleAction: GXActionBlock?

    var topAssets: [PhotoAsset] = []
    lazy var banner: GXBanner = {
        let frame: CGRect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 96)
        return GXBanner(frame: frame, margin: 0, lineSpacing: 0).then {
            $0.backgroundColor = UIColor.gx_background
            $0.pageControl.currentPageIndicatorTintColor = .gx_green
            $0.pageControlBottomGap = 30.0
            $0.autoTimeInterval = 5.0
            $0.isAutoPlay = true
            $0.dataSource = self
            $0.delegate = self
            $0.register(classCellType: GXParticipantHomeDtBannerConCell.self)
        }
    }()

    class func height(data: GXActivityBaseInfoData?) -> CGFloat {
        let title = data?.activityName ?? ""
        let font = UIFont.gx_PFSCfont(size: 18, type: .medium)
        let nameHeight = title.height(width: SCREEN_WIDTH-32, font: font)
        return 482 + nameHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.activityNameLabel.text = nil
        self.signedFavoriteNumLabel.text = nil
        self.activityDateLabel.text = nil
        self.activityAddressLabel.text = nil
        self.activityAddressDescLabel.text = nil
        self.normalPriceLabel.text = nil
        self.vipPriceLabel.text = nil
        self.activityTicketTypeIView.image = nil
        self.activitLimitLabel.text = nil
        
        self.activityConView.addSubview(self.banner)
        self.banner.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.activityNameLabel.preferredMaxLayoutWidth = self.activityNameLabel.frame.width
        self.activityAddressLabel.preferredMaxLayoutWidth = self.activityAddressLabel.frame.width
        self.activityAddressDescLabel.preferredMaxLayoutWidth = self.activityAddressDescLabel.frame.width
    }

    func bindModel(data: GXActivityBaseInfoData?, topAssets: [PhotoAsset], isShowCMapBtn: Bool = false) {
        self.cdMapButton.isHidden = !isShowCMapBtn
        self.cdMapLabel.isHidden = !isShowCMapBtn
        guard let model = data else { return }
        
        self.topAssets = topAssets
        self.banner.reloadData()

        self.activityNameLabel.text = model.activityName
        self.signedFavoriteNumLabel.text = "\(model.favoriteNum)人感兴趣  \(model.signedNum)人已报名"
        self.activityDateLabel.text = model.startToEndDateString()
        self.activityAddressLabel.text = model.showCityName()
        self.activityAddressDescLabel.text = model.showAddress()
        if model.limitJoinNum == 1 {
            self.activitLimitLabel.text = "限\(model.joinNum)人"
        } else {
            self.activitLimitLabel.text = nil
        }

        // VIP价格？早鸟价？
        let vipFlag: Bool = (GXUserManager.shared.user?.vipFlag ?? false)
        let signUpModel = model.getSignUpModel()
        self.setPriceLabel(ticket: signUpModel.ticket, activityMode: model.activityMode, isVip: vipFlag)

        let distance = GXLocationManager.shared.getUserDistanceTo(latitude:model.latitude, longitude: model.longitude)
        self.locationLabel.text = distance
    }

    func setPriceLabel(ticket: GXActivityticketlistItem?, activityMode: Int, isVip: Bool) {
        guard let ticketItem = ticket, activityMode == 2 else {
            self.normalPriceLabel.attributedText = nil
            self.vipPriceLabel.text = "免费"
            self.activityTicketTypeIView.image = nil
            return
        }
        if ticketItem.ticketType == 2 {
            if ticketItem.vipPrice.count > 0 && isVip {
                self.vipPriceLabel.text = "￥\(ticketItem.vipPrice)"
            }
            else {
                self.vipPriceLabel.text = "￥\(ticketItem.normalPrice)"
            }
            self.normalPriceLabel.attributedText = nil
            self.activityTicketTypeIView.image = UIImage(named: "a_znj_icon")
        }
        else {
            let vipPrice: Float = Float(ticketItem.vipPrice) ?? 0
            let normalPrice: Float = Float(ticketItem.normalPrice) ?? 0
            if (vipPrice == 0 && normalPrice == 0) || (!isVip && normalPrice == 0) {
                self.normalPriceLabel.attributedText = nil
                self.vipPriceLabel.text = "免费"
                self.activityTicketTypeIView.image = nil
                return
            }
            if ticketItem.vipPrice.count > 0 && isVip {
                self.vipPriceLabel.text = "￥\(ticketItem.vipPrice)"
                let normalPriceStr = "￥\(ticketItem.normalPrice)"
                let attrDic: [NSAttributedString.Key: Any] = [
                    .strikethroughStyle: NSNumber.init(value: 1),
                    .foregroundColor: UIColor.gx_gray,
                    .font: UIFont.gx_font(size: 13)
                ]
                let attributedString = NSMutableAttributedString(string: normalPriceStr, attributes: attrDic)
                self.normalPriceLabel.attributedText = attributedString
                self.activityTicketTypeIView.image = UIImage(named: "a_vipj_icon")
            }
            else {
                self.normalPriceLabel.attributedText = nil
                self.vipPriceLabel.text = "￥\(ticketItem.normalPrice)"
                self.activityTicketTypeIView.image = nil
            }
        }
    }

}

extension GXPublishActivityDetailCell: GXBannerDataSource, GXBannerDelegate {
    // MARK: - GXBannerDataSource
    func numberOfItems() -> Int {
        return self.topAssets.count
    }
    func banner(_ banner: GXBanner, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXParticipantHomeDtBannerConCell = banner.dequeueReusableCell(for: indexPath)
        cell.bindModel(asset: self.topAssets[indexPath.item])

        return cell
    }
    // MARK: - GXBannerDelegate
    func banner(_ banner: GXBanner, didSelectItemAt indexPath: IndexPath) {
        NSLog("didSelectItemAt %d", indexPath.row)
    }
}

extension GXPublishActivityDetailCell {
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        self.locationAction?()
    }

    @IBAction func cdMapButtonClicked(_ sender: UIButton) {
        self.cdmapAction?()
    }

    @IBAction func activityRuleButtonClicked(_ sender: UIButton) {
        self.ruleAction?()
    }
}
