//
//  GXActivityDetailTextCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit
import Reusable

class GXActivityDetailTextCell: UITableViewCell, NibReusable {
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(model: GXActivityRuleInfoData?) {
        guard let data = model else { return }
        let attributedText: NSAttributedString = data.compositeText()
        self.contentLabel.attributedText = attributedText
    }

}
