//
//  GXPublishQuestionnaireListCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import Reusable

class GXPublishQuestionnaireListCell: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.statusLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.statusLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXPublishQuestionaireDetailData) {
        self.nameLabel.text = model.questionaireName
        if let date = Date.date(dateString: model.createTime ?? "", format: "yyyy-MM-dd HH:mm:ss") {
            self.dateLabel.text = date.string(format: "yyyy年MM月dd日 HH:mm") + " 创建"
        } else {
            self.dateLabel.text = (model.createTime ?? "") + " 创建"
        }
        // 问卷状态 0-草稿 1-待审核 2-已审核 3-进行中 4-已结束 5-审核未通过
        switch model.questionaireStatus {
        case 0:
            self.statusLabel.text = "草稿"
            self.statusLabel.textColor = .gx_drakGreen
        case 1:
            self.statusLabel.text = "平台审核中"
            self.statusLabel.textColor = .gx_yellow
        case 2:
            self.statusLabel.text = "审核通过"
            self.statusLabel.textColor = .gx_drakGreen
        case 3:
            self.statusLabel.text = "进行中"
            self.statusLabel.textColor = .gx_drakGreen
        case 4:
            self.statusLabel.text = "已结束"
            self.statusLabel.textColor = .gx_drakGray
        case 5:
            self.statusLabel.text = "平台审核未通过"
            self.statusLabel.textColor = .gx_red
        default: break
        }
    }

}
