//
//  GXPublishQuestionnaireDetailTopCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/21.
//

import UIKit
import Reusable

class GXPublishQuestionnaireDetailTopCell: UITableViewCell, NibReusable {
    /// 问卷对象-报名用户
    @IBOutlet weak var signUserButton: UIButton!
    /// 问卷对象-App全员
    @IBOutlet weak var allUserButton: UIButton!
    /// 问卷说明
    @IBOutlet weak var descLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXPublishQuestionaireDetailData?) {
        guard let data = model else { return }
        
        self.setQuestionaireTarget(type: data.questionaireTarget ?? 0)
        self.descLabel.text = data.questionaireDesc
    }

    /// 问卷对象 1-活动 2-app全员
    func setQuestionaireTarget(type: Int) {
        if type == 2 {
            self.signUserButton.isSelected = false
            self.allUserButton.isSelected = true
        }
        else if type == 1 {
            self.signUserButton.isSelected = true
            self.allUserButton.isSelected = false
        }
        else {
            self.signUserButton.isSelected = false
            self.allUserButton.isSelected = false
        }
    }

}
