//
//  GXPublishActivityDetailUserCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/14.
//

import UIKit
import Reusable

class GXPublishActivityDetailUserCell: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarIView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var openButton: GXArrowButton!
    @IBOutlet weak var tagsView: GXCollectionTagsView!

    var openAction: GXActionBlockItem<Bool>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.openButton.imageLocationAdjust(model: .right, spacing: 4.0)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.containerView.backgroundColor = .gx_lightGray
        } else {
            self.containerView.backgroundColor = .gx_background
        }
    }
    
    func bindModel(data: GXActivityBaseInfoData?, isOpen: Bool) {
        guard let model = data else { return }

        self.openButton.isSelected = isOpen
        self.avatarIView.kf.setImage(with: URL(string: model.avatarPic), placeholder: UIImage.gx_defaultAvatar)
        self.nameLabel.text = model.nickName
        self.tagsView.updateTags(isVip: model.vipFlag,
                                 isSm: model.realnameFlag,
                                 isJg: model.orgAccreditationFlag,
                                 isGf: model.officialFlag,
                                 isDr: model.expertFlag)
    }
    
    @IBAction func openButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.openAction?(sender.isSelected)
    }
}
