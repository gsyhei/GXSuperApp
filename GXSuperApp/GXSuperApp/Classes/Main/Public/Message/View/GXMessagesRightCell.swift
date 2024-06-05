//
//  GXMessagesRightCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/22.
//

import UIKit
import Reusable
import CollectionKit
import HXPhotoPicker

class GXMessagesRightCell: UITableViewCell, NibReusable {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!

    var avatarAction: GXActionBlockItem<GXMessagesRightCell>?
    var imageAction: GXActionBlockItem<GXMessagesRightCell>?

    class func height(view: UIView, model: GXListUserMessagesItem?) -> CGFloat {
        guard let model = model else { return .zero }
        var height: CGFloat = 48.0 + 16.0
        height += model.chatContent.height(width: view.frame.width - 70, font: .gx_font(size: 15))
        if model.chatPic.count > 0 {
            height += 108.0
        }
        return height
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.nameLabel.text = nil
        self.avatarButton.setImage(.gx_defaultAvatar, for: .normal)
        self.contentLabel.text = nil
        self.dateLabel.text = nil
        self.chatImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.nameLabel.text = nil
        self.avatarButton.setImage(.gx_defaultAvatar, for: .normal)
        self.contentLabel.text = nil
        self.dateLabel.text = nil
        self.chatImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizer(_:)))
        self.chatImageView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    /// 设置主题类型
    /// - Parameter type: 0-黑色，1-白色
    func setThemeType(type: Int) {
        if type == 1 {
            self.backgroundColor = .white
            self.backgroundColor = .white
            self.nameLabel.textColor = .gx_black
            self.contentLabel.textColor = .gx_black
            self.dateLabel.textColor = .gx_drakGray
        }
        else {
            self.backgroundColor = .black
            self.backgroundColor = .black
            self.nameLabel.textColor = .white
            self.contentLabel.textColor = .white
            self.dateLabel.textColor = .gx_gray
        }
    }

    func bindCell(model: GXListUserMessagesItem?) {
        guard let item = model else { return }

        self.nameLabel.text = item.nickName
        self.avatarButton.kf.setImage(with: URL(string: item.avatarPic), for: .normal, placeholder: UIImage.gx_defaultAvatar)
        self.contentLabel.text = item.chatContent
        if item.updateTime.count > 16 {
            self.dateLabel.text = item.updateTime[0, 16]
        } else {
            self.dateLabel.text = item.updateTime
        }
        if item.chatPic.count > 0 {
            self.chatImageView.kf.setImage(with: URL(string: item.chatPic), placeholder: UIImage.gx_defaultActivityIcon)
        }
        else {
            self.chatImageView.image = nil
        }
    }
}

extension GXMessagesRightCell {

    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        self.avatarAction?(self)
    }

    @objc func tapGestureRecognizer(_ sender: Any?){
        self.imageAction?(self)
    }

}
