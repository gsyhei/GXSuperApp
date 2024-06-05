//
//  GXChatGroupMemberCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/24.
//

import UIKit
import Reusable

class GXChatGroupMemberCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var staffsIView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override var isHighlighted: Bool {
        didSet {
            self.avatarButton.isHighlighted = isHighlighted
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindCell(model: GXActivityUser?) {
        guard let model = model else {
            self.nameLabel.text = "更多"
            self.staffsIView.isHidden = true
            self.avatarButton.setBackgroundImage(UIImage.gx_defaultAvatar, for: .normal)
            self.avatarButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            self.avatarButton.tintColor = .white
            return
        }
        self.avatarButton.setImage(nil, for: .normal)
        self.avatarButton.kf.setBackgroundImage(with: URL(string: model.avatarPic), for: .normal, placeholder: UIImage.gx_defaultAvatar)
        self.nameLabel.text = model.nickName
        self.staffsIView.isHidden = !model.isStaffs
    }
}
