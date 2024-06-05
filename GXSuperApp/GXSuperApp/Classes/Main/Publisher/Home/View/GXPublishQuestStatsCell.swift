//
//  GXPublishQuestStatsCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/7.
//

import UIKit
import Reusable

class GXPublishQuestStatsCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitNumLabel: UILabel!
    @IBOutlet weak var submitRateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXOptionreportsModel?) {
        guard let data = model else { return }
        self.titleLabel.text = data.optionTitle
        self.submitNumLabel.text = "\(data.submitNum)"
        self.submitRateLabel.text = "\(data.submitRate)%"
    }
}
