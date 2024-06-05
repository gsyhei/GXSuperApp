//
//  GXPublishEventListCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import Reusable

class GXPublishEventListCell: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.statusLabel.text = nil
        self.addressLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.dateLabel.text = nil
        self.statusLabel.text = nil
        self.addressLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXPublishEventStepData?) {
        guard let data = model else { return }

        self.nameLabel.text = data.eventTitle
        self.addressLabel.text = data.address
        self.dateLabel.text = data.startToEndDateString()
        
        /// 事件状态 0-禁用 1-启用 2- 3-平台禁用
        switch data.eventStatus {
        case 0:
            self.statusLabel.text = "禁用"
            self.statusLabel.textColor = .gx_red
        case 1:
            self.statusLabel.text = "启用"
            self.statusLabel.textColor = .gx_drakGreen
        case 2:
            self.statusLabel.text = "启用"
            self.statusLabel.textColor = .gx_drakGreen
        case 3:
            self.statusLabel.text = "平台禁用"
            self.statusLabel.textColor = .gx_red
        default: break
        }
    }
    
}
