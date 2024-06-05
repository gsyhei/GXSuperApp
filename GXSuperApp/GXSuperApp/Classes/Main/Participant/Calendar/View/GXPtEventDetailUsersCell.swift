//
//  GXPtEventDetailUsersCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/1.
//

import UIKit
import Reusable

class GXPtEventDetailUsersCell: UITableViewCell, NibReusable {
    @IBOutlet weak var avatarIView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.avatarIView.image = nil
        self.nameLabel.text = nil
        self.rankLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXPublishEventsignsData?, index: Int) {
        guard let data = model else { return }

        self.avatarIView.kf.setImage(with: URL(string: data.avatarPic ?? ""), placeholder: UIImage.gx_defaultAvatar)
        self.nameLabel.text = data.nickName
        self.rankLabel.text = data.eventReward
        switch index {
        case 0:
            self.rankLabel.textColor = .gx_red
        case 1:
            self.rankLabel.textColor = .gx_yellow
        case 2:
            self.rankLabel.textColor = .gx_drakGreen
        default:
            self.rankLabel.textColor = .gx_black
        }
    }
}
