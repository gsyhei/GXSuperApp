//
//  GXMinePtAddFansPageCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/9.
//

import UIKit
import Reusable

class GXMinePtAddFansPageCell: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var attentionButton: UIButton!

    var attentionAction: GXActionBlockItem<GXMinePtAddFansPageCell>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nicknameLabel.text = nil
        self.infoLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nicknameLabel.text = nil
        self.infoLabel.text = nil
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.containerView.backgroundColor = highlighted ? .gx_lightGray:.white
    }

    func bindCell(model: GXListMyFansItem?, isMyFans: Bool) {
        guard let model = model else { return }
        
        self.avatarButton.kf.setImage(with: URL(string: model.avatarPic), for: .normal, placeholder: UIImage.gx_defaultAvatar)
        self.nicknameLabel.text = model.nickName
        self.infoLabel.text = model.personalIntroduction
        
        if isMyFans {
            if model.followEachOther {
                self.attentionButton.setTitle("互相关注", for: .normal)
                self.attentionButton.gx_setGrayBorderButton()
            }
            else {
                self.attentionButton.setTitle("回关", for: .normal)
                self.attentionButton.gx_setGreenButton()
            }
        }
        else{
            if model.isDelete {
                self.attentionButton.setTitle("关注", for: .normal)
                self.attentionButton.gx_setGreenButton()
            }
            else {
                if model.followEachOther {
                    self.attentionButton.setTitle("互相关注", for: .normal)
                    self.attentionButton.gx_setGrayBorderButton()
                }
                else {
                    self.attentionButton.setTitle("已关注", for: .normal)
                    self.attentionButton.gx_setGrayBorderButton()
                }
            }
        }
    }

    func bindCell(model: GXListMyFansItem?) {
        guard let model = model else { return }

        self.avatarButton.kf.setImage(with: URL(string: model.avatarPic), for: .normal, placeholder: UIImage.gx_defaultAvatar)
        self.nicknameLabel.text = model.nickName
        self.infoLabel.text = model.personalIntroduction

        if model.followEachOther {
            self.attentionButton.setTitle("已关注", for: .normal)
            self.attentionButton.gx_setGrayBorderButton()
        }
        else {
            self.attentionButton.setTitle("关注", for: .normal)
            self.attentionButton.gx_setGreenButton()
        }
    }
}

extension GXMinePtAddFansPageCell {
    @IBAction func attentionButtonClicked(_ sender: UIButton) {
        self.attentionAction?(self)
    }
}
