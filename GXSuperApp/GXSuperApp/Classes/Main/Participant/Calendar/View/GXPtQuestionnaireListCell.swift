//
//  GXPtQuestionnaireListCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import Reusable

class GXPtQuestionnaireListCell: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var attendButton: UIButton!

    var attendAction: GXActionBlockItem<GXPtQuestionnaireListCell>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.text = nil
        self.dateLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.dateLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    class func heightCell(model: GXPublishQuestionaireDetailData?) -> CGFloat {
        //guard let data = model else { return .zero }
        var height: CGFloat = 36.0
        height += UIFont.gx_boldFont(size: 15).lineHeight //data.questionaireName?.height(width: SCREEN_WIDTH - 136, font: .gx_boldFont(size: 15)) ?? 0
        height += UIFont.gx_font(size: 13).lineHeight
        
        return height
    }

    func bindCell(model: GXPublishQuestionaireDetailData?, isHiddenEndStatus: Bool = false) {
        guard let data = model else { return }

        self.nameLabel.text = data.questionaireName
        if let date = Date.date(dateString: data.createTime ?? "", format: "yyyy-MM-dd HH:mm:ss") {
            self.dateLabel.text = date.string(format: "yyyy年MM月dd日 HH:mm") + " 创建"
        } else {
            self.dateLabel.text = (data.createTime ?? "") + " 创建"
        }
        // 问卷状态 0-草稿 1-待审核 2-已审核 3-进行中 4-已结束 5-审核未通过
        if data.questionaireStatus == 4 {
            if model?.submitFlag ?? false {
                self.attendButton.isHidden = false
                self.attendButton.setTitle("查看", for: .normal)
                self.attendButton.gx_setGrayButton()
            }
            else {
                self.attendButton.setTitle("已结束", for: .normal)
                self.attendButton.gx_setDisabledButton()
                self.attendButton.isHidden = isHiddenEndStatus
            }
        }
        else {
            if model?.submitFlag ?? false {
                self.attendButton.isHidden = false
                self.attendButton.setTitle("查看", for: .normal)
                self.attendButton.gx_setGrayButton()
            }
            else {
                self.attendButton.isHidden = false
                self.attendButton.setTitle("去填写", for: .normal)
                self.attendButton.gx_setGreenButton()
            }
        }
    }
}

extension GXPtQuestionnaireListCell {

    @IBAction func attendButtonClicked(_ sender: UIButton) {
        self.attendAction?(self)
    }

}
