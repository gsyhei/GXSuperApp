//
//  GXMinePrOrderDetailCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit
import Reusable

class GXMinePrOrderDetailCell: UITableViewCell, NibReusable {
    @IBOutlet weak var infoTiLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var avatarIView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.infoLabel.text = nil
        self.avatarIView.image = nil
        self.nameLabel.text = nil
        self.phoneLabel.text = nil

        let infoTi = self.infoTiLabel.text ?? ""
        let infoTiAttr = NSMutableAttributedString(string: infoTi)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.0
        infoTiAttr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: infoTi.count))
        self.infoTiLabel.attributedText = infoTiAttr
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(model: GXMinePrOrderDetailData?) {
        guard let model = model else { return }

        self.avatarIView.kf.setImage(with: URL(string: model.avatarPic), placeholder: UIImage.defaultAvatar)
        self.nameLabel.text = model.nickName
        self.phoneLabel.text = model.phone

        var info = model.orderSn
        info += "\n" + String(model.activityId)
        info += "\n" + String(model.paidTime)
        info += "\n￥" + String(model.totalPrice)
        // 支付方式 1-支付宝 2-微信
        if model.paidType == 2 {
            info += "\n" + "微信"
        } else {
            info += "\n" + "支付宝"
        }
        info += "\n" + String(model.ticketTime)
        // 门票状态 0-未使用 1-已使用 2-平台禁用 3-已过期
        var ticketStatus = ""
        var ticketStatusColor: UIColor = .gx_gray
        switch model.ticketStatus {
        case 0:
            ticketStatusColor = .gx_drakGreen
            ticketStatus = "未使用"
        case 1:
            ticketStatus = "已使用"
        case 2:
            ticketStatus = "平台禁用"
        case 3:
            ticketStatus = "已过期"
        default:
            ticketStatus = "未知"
        }
        info += "\n" + ticketStatus
        let infoAttr = NSMutableAttributedString(string: info)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.0
        infoAttr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: info.count))
        let range = NSRange(location: info.count - ticketStatus.count, length: ticketStatus.count)
        infoAttr.addAttribute(.foregroundColor, value: ticketStatusColor, range: range)
        self.infoLabel.attributedText = infoAttr
    }

}
