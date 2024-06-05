//
//  GXParticipantHomeDtButtonCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit
import Reusable

class GXParticipantHomeDtButtonCell: UITableViewCell, NibReusable {
    @IBOutlet weak var calendarTopLabel: UILabel!
    @IBOutlet weak var questiTopLabel: UILabel!
    @IBOutlet weak var noticeTopLabel: UILabel!

    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var questiLabel: GXMarqueeTextView!
    @IBOutlet weak var noticeLabel: GXMarqueeTextView!
    var aqtModel: GXPtHomeActQueTicketData?
    var buttonAction: GXActionBlockItem2<Int, GXPtHomeActQueTicketData?>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .gx_background
        self.contentView.backgroundColor = .gx_background
        self.questiLabel.textFont = .gx_font(size: 11)
        self.questiLabel.textColor = .gx_drakGray
        self.noticeLabel.textFont = .gx_font(size: 11)
        self.noticeLabel.textColor = .gx_drakGray

        self.calendarTopLabel.font = .gx_dingTalkFont(size: 15)
        self.questiTopLabel.font = .gx_dingTalkFont(size: 15)
        self.noticeTopLabel.font = .gx_dingTalkFont(size: 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(model: GXPtHomeActQueTicketData?) {
        guard let data = model else { return }
        self.aqtModel = data

        let activityNum = " \(data.todayActivityNum) "
        let activityString = "上新活动" + activityNum + "个"
        let attributedString = NSMutableAttributedString(string: activityString)
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.gx_red,
                                      range: NSRange(location: 4, length: activityNum.count))
        self.calendarLabel.attributedText = attributedString

        if data.questionaireName.isEmpty {
            self.questiLabel.text = "暂无问卷信息"
        } else {
            self.questiLabel.text = data.questionaireName
        }
        if data.broadcastTitle.isEmpty {
            self.noticeLabel.text = "暂无抢票信息"
        } else {
            self.noticeLabel.text = data.broadcastTitle
        }
    }
}

extension GXParticipantHomeDtButtonCell {
    @IBAction func calendarButtonClicked(_ sender: UIButton) {
        self.buttonAction?(0, self.aqtModel)
    }
    @IBAction func questiButtonClicked(_ sender: UIButton) {
        self.buttonAction?(1, self.aqtModel)
    }
    @IBAction func noticeButtonClicked(_ sender: UIButton) {
        self.buttonAction?(2, self.aqtModel)
    }
}
