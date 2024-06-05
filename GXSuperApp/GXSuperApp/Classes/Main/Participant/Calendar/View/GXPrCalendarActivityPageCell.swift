//
//  GXPrCalendarActivityPageCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit
import Reusable

class GXPrCalendarActivityPageCell: UITableViewCell, NibReusable {
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityTypeNameLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var signedFavoriteNumLabel: UILabel!
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var activityAddressLabel: UILabel!
    @IBOutlet weak var normalPriceLabel: UILabel!
    @IBOutlet weak var vipPriceLabel: UILabel!
    @IBOutlet weak var activityTicketTypeIView: UIImageView!
    @IBOutlet weak var activityStatusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.activityImageView.image = nil
        self.activityTypeNameLabel.text = nil
        self.activityNameLabel.text = nil
        self.signedFavoriteNumLabel.text = nil
        self.activityDateLabel.text = nil
        self.activityAddressLabel.text = nil
        self.normalPriceLabel.text = nil
        self.vipPriceLabel.text = nil
        self.activityTicketTypeIView.image = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.activityImageView.image = nil
        self.activityTypeNameLabel.text = nil
        self.activityNameLabel.text = nil
        self.signedFavoriteNumLabel.text = nil
        self.activityDateLabel.text = nil
        self.activityAddressLabel.text = nil
        self.normalPriceLabel.text = nil
        self.vipPriceLabel.text = nil
        self.activityTicketTypeIView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(model: GXCalendarActivityItem?) {
        guard let data = model else { return }

        let imageUrlArr = data.listPics.components(separatedBy: ",")
        if let imageUrlStr = imageUrlArr.first, imageUrlStr.count > 0 {
            self.activityImageView.kf.setImage(with: URL(string: imageUrlStr), placeholder: UIImage.gx_defaultActivityIcon)
        } else {
            self.activityImageView.kf.setImage(with: URL(string: data.listPics), placeholder: UIImage.gx_defaultActivityIcon)
        }
        self.activityTypeNameLabel.text = data.activityTypeName

        self.activityNameLabel.text = data.activityName
        self.signedFavoriteNumLabel.text = "\(data.favoriteNum)人感兴趣  \(data.signedNum)人已报名"
        self.activityDateLabel.text = data.startToEndDateString()
        self.activityAddressLabel.text = data.showCityName()

        // 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过
        switch data.activityStatus {
        case 1:
            self.activityStatusLabel.textColor = .gx_drakGreen
            self.activityStatusLabel.text = "待审核"
        case 2:
            self.activityStatusLabel.textColor = .gx_drakGreen
            self.activityStatusLabel.text = "未开始"
        case 3:
            self.activityStatusLabel.textColor = .gx_pink
            self.activityStatusLabel.text = "进行中"
        case 4:
            self.activityStatusLabel.textColor = .gx_red
            self.activityStatusLabel.text = "已结束"
        case 5:
            self.activityStatusLabel.textColor = .gx_red
            self.activityStatusLabel.text = "审核未通过"
        default: break
        }
        
        // VIP价格？早鸟价？
        let vipFlag: Bool = (GXUserManager.shared.user?.vipFlag ?? false)
        if data.activityTickets.count > 0 && data.activityTicket == nil {
            let signUpModel = data.getSignUpModel()
            self.setPriceLabel(ticket: signUpModel.ticket, activityMode: data.activityMode, isVip: vipFlag)
        } else {
            self.setPriceLabel(ticket: data.activityTicket, activityMode: data.activityMode, isVip: vipFlag)
        }
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

    func bindCell(model: GXMinePrOrderDetailData?) {
        guard let data = model else { return }

        self.signedFavoriteNumLabel.isHidden = true
        let imageUrlArr = data.listPics.components(separatedBy: ",")
        if let imageUrlStr = imageUrlArr.first, imageUrlStr.count > 0 {
            self.activityImageView.kf.setImage(with: URL(string: imageUrlStr), placeholder: UIImage.gx_defaultActivityIcon)
        } else {
            self.activityImageView.kf.setImage(with: URL(string: data.listPics), placeholder: UIImage.gx_defaultActivityIcon)
        }
        self.activityTypeNameLabel.text = data.activityTypeName
        self.activityNameLabel.text = data.activityName
        self.activityDateLabel.text = data.startToEndDateString()
        self.activityAddressLabel.text = data.showCityName()
    }

}

