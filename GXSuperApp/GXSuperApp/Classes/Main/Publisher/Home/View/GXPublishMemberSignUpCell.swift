//
//  GXPublishMemberSignUpCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import UIKit
import Reusable

class GXPublishMemberSignUpCell: UITableViewCell, NibReusable {
    @IBOutlet weak var checkedButton: UIButton!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hexiaoTagLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var vipIconIView: UIImageView!

    @IBOutlet weak var layoutAllLineLeftLC: NSLayoutConstraint!
    @IBOutlet weak var layoutPhoneLeftLC: NSLayoutConstraint!
    var avatarAction: GXActionBlockItem<GXPublishMemberSignUpCell>?

    var isChecked: Bool = false {
        didSet {
            self.checkedButton.isSelected = isChecked
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bindCell(model: GXActivitysignsCellModel, activityData: GXActivityBaseInfoData?) {
        let data = model.item

        // 活动模式 1-免费报名模式 2-卖票模式
        if activityData?.activityMode == 2 || !GXRoleUtil.isTeller(roleType: activityData?.roleType) {
            self.layoutAllLineLeftLC.constant = 0
            self.checkedButton.isHidden = true
        }
        else {
            self.layoutAllLineLeftLC.constant = 40
            self.checkedButton.isHidden = false
        }
        self.isChecked = model.isChecked
        self.avatarButton.kf.setImage(with: URL(string: data.avatarPic), for: .normal, placeholder: UIImage.defaultAvatar)
        self.nameLabel.text = data.nickName
        
        if data.verifyFlag == 1 {
            self.hexiaoTagLabel.isHidden = false
            self.layoutPhoneLeftLC.constant = 46
        }
        else {
            self.hexiaoTagLabel.isHidden = true
            self.layoutPhoneLeftLC.constant = 0
        }
        self.phoneLabel.text = data.phone

        // [yyyy-MM-dd HH:mm:ss]
        let date = Date.date(dateString: data.signTime, format: "yyyy-MM-dd HH:mm:ss")
        self.dateLabel.text = date?.string(format: "yyyy.MM.dd")
        self.priceLabel.text = String(format: "%.2f", data.paidMoney)
        self.vipIconIView.isHidden = (data.vipFlag == 0)
    }

}

extension GXPublishMemberSignUpCell {
    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        self.avatarAction?(self)
    }
}
