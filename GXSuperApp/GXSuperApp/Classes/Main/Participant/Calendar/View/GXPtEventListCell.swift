//
//  GXPtEventListCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import Reusable

class GXPtEventListCell: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var attendButton: UIButton!

    var attendAction: GXActionBlockItem<GXPtEventListCell>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.addressLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.addressLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    class func heightCell(model: GXPublishEventStepData?) -> CGFloat {
        guard let data = model else { return .zero }
        var height: CGFloat = 38.0
        height += data.eventTitle?.height(width: SCREEN_WIDTH - 136, font: .gx_boldFont(size: 15)) ?? 0
        height += UIFont.gx_font(size: 13).lineHeight
        height += data.address?.height(width: SCREEN_WIDTH - 52, font: .gx_font(size: 13)) ?? 0

        return height
    }

    func bindCell(model: GXPublishEventStepData?) {
        guard let data = model else { return }

        self.nameLabel.text = data.eventTitle
        self.addressLabel.text = data.address
        self.dateLabel.text = data.startToEndDateString()

        // 事件状态 0-禁用 1-启用-进行中 2-启用-已结束 3-平台禁用
        if data.eventStatus == 2 {
            self.attendButton.setTitle("查看", for: .normal)
            self.attendButton.gx_setGrayButton()
        }
        else {
            let signUpEndStr = (data.signEndDate ?? "") + "-" + (data.signEndTime ?? "")
            let signUpEndDate = Date.date(dateString: signUpEndStr, format: "yyyyMMdd-HH:mm") ?? Date()
            if signUpEndDate > GXServiceManager.shared.systemDate {
                self.attendButton.setTitle("立即参与", for: .normal)
                self.attendButton.gx_setGreenButton()
            }
            else {
                self.attendButton.setTitle("查看", for: .normal)
                self.attendButton.gx_setGrayButton()
            }
        }
    }

    @IBAction func attendButtonClicked(_ sender: UIButton) {
        self.attendAction?(self)
    }
    
}
