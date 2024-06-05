//
//  GXTicketsListCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import UIKit
import Reusable

class GXTicketsListCell: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityTypeNameLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var activityAddressLabel: UILabel!
    @IBOutlet weak var activityStatusLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!

    @IBOutlet weak var ticketContentView: UIView!
    @IBOutlet weak var leftLineImageView: UIImageView!
    @IBOutlet weak var rightVipImageView: UIImageView!
    @IBOutlet weak var qrcodeContentView: UIView!
    @IBOutlet weak var qrcodeImageView: UIImageView!

    var checked: Bool = false {
        didSet {
            self.ticketContentView.isHidden = !checked
            self.openButton.isSelected = checked
        }
    }

    var openAction: GXActionBlockItem2<GXTicketsListCell, Bool>?
    var openQrcodeAction: GXActionBlockItem2<GXTicketsListCell, UIImage>?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(qrcodeTapped(_:)))
        self.qrcodeContentView.addGestureRecognizer(tap)
        self.openButton.hitEdgeInsets = UIEdgeInsets(top: 0, left: -28, bottom: 0, right: -28)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.containerView.backgroundColor = highlighted ? .gx_lightGray:.white
    }

    func bindCell(model: GXListMyTicketItem, ticketStatus: Int) {
        let imageUrlArr = model.listPics.components(separatedBy: ",")
        if let imageUrlStr = imageUrlArr.first, imageUrlStr.count > 0 {
            self.activityImageView.kf.setImage(with: URL(string: imageUrlStr), placeholder: UIImage.gx_defaultActivityIcon)
        } else {
            self.activityImageView.kf.setImage(with: URL(string: model.listPics), placeholder: UIImage.gx_defaultActivityIcon)
        }
        self.activityTypeNameLabel.text = model.activityTypeName

        self.activityNameLabel.text = model.activityName
        self.activityDateLabel.text = model.startToEndDateString()
        self.activityAddressLabel.text = model.showCityName()

        // 活动状态 0-草稿 1-待审核 2-未开始 3-进行中 4-已结束 5-审核未通过
        switch model.activityStatus {
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

        // 门票状态 0-未使用 1-已使用
        if ticketStatus == 1 {
            self.rightVipImageView.isHidden = true
            self.leftLineImageView.image = UIImage(named: "t_used_line")
            self.qrcodeContentView.backgroundColor = .gx_drakGray
        }
        else {
            let isVip = (GXUserManager.shared.user?.vipFlag ?? false)
            if isVip {
                self.rightVipImageView.isHidden = false
                self.leftLineImageView.image = UIImage(named: "t_vnot_line")
                self.qrcodeContentView.backgroundColor = .gx_yellow
            }
            else {
                self.rightVipImageView.isHidden = true
                self.leftLineImageView.image = UIImage(named: "t_not_line")
                self.qrcodeContentView.backgroundColor = .gx_drakGray
            }
        }
        let qrCodeString = GXUtil.gx_qrCode(type: .ticket, text: model.ticketCode)
        UIImage.createQRCodeImage(text: qrCodeString) {[weak self] image in
            self?.qrcodeImageView.image = image
        }
    }

}

extension GXTicketsListCell {
    @IBAction func openButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.checked = sender.isSelected
        self.openAction?(self, self.checked)
    }
    @objc func qrcodeTapped(_ sender: Any?) {
        if let image = self.qrcodeImageView.image {
            self.openQrcodeAction?(self, image)
        }
    }
}

