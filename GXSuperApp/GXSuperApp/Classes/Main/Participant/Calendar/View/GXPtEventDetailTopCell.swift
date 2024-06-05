//
//  GXPtEventDetailTopCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/31.
//

import UIKit
import Reusable

class GXPtEventDetailTopCell: UITableViewCell, NibReusable {
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addrssLabel: UILabel!
    @IBOutlet weak var picInfoLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(model: GXPublishEventStepData, mapPics: String?) {
        self.descLabel.text = model.eventDesc
        self.dateLabel.text = model.startToEndDateString()
        self.addrssLabel.text = model.address
    }

}
