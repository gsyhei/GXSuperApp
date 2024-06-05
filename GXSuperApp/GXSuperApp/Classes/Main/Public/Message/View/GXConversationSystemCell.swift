//
//  GXConversationSystemCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit
import Reusable

class GXConversationSystemCell: UITableViewCell, NibReusable {
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lookButton: UIButton!

    var lookAction: GXActionBlockItem<GXConversationSystemCell>?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.tagView.isHidden = true
        self.lookButton.setBackgroundColor(.gx_green, for: .normal)
        self.contentLabel.text = nil
        self.dateLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentLabel.text = nil
        self.dateLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(model: GXListSystemMessagesItem?) {
        guard let model = model else { return }

        self.tagView.isHidden = model.readFlag
        self.contentLabel.font = model.readFlag ? .gx_font(size: 15):.gx_boldFont(size: 15)
        self.contentLabel.text = model.messageContent
        self.dateLabel.text = model.updateTime
    }
}

extension GXConversationSystemCell {
    @IBAction func lookButtonClicked(_ sender: UIButton) {
        self.lookAction?(self)
    }
}
