//
//  GXConversationCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/13.
//

import UIKit
import Reusable

class GXConversationCell: UITableViewCell, NibReusable {
    @IBOutlet weak var avatarIView: UIImageView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIView.image = nil
        self.avatarIView.contentMode = .scaleAspectFill
        self.nameLabel.text = nil
        self.contentLabel.text = nil
        self.dateLabel.text = nil
        self.tagView.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarIView.image = nil
        self.nameLabel.text = nil
        self.contentLabel.text = nil
        self.dateLabel.text = nil
        self.tagView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXListUserMessagesItem?) {
        guard let model = model else { return }

        self.backgroundColor = (model.setTop == 1) ? .gx_background:.white
        self.tagView.isHidden = !model.redPoint
        let imageUrlArr = model.listPics.components(separatedBy: ",")
        if let imageUrlStr = imageUrlArr.first, imageUrlStr.count > 0 {
            self.avatarIView.kf.setImage(with: URL(string: imageUrlStr), placeholder: UIImage.gx_defaultActivityIcon)
        } else {
            self.avatarIView.kf.setImage(with: URL(string: model.listPics), placeholder: UIImage.gx_defaultActivityIcon)
        }
        self.nameLabel.text = model.activityName
        self.contentLabel.text = model.chatContent

        if let date = Date.date(dateString: model.updateTime, format: "yyyy-MM-dd HH:mm:ss") {
            if date.isToday {
                self.dateLabel.text = date.string(format: "HH:mm")
            }
            else if date.isYesterday {
                self.dateLabel.text = date.string(format: "昨天 HH:mm")
            }
            else {
                self.dateLabel.text = date.string(format: "yyyy.MM.dd HH:mm")
            }
        }
        else {
            self.dateLabel.text = model.updateTime
        }
    }

}
