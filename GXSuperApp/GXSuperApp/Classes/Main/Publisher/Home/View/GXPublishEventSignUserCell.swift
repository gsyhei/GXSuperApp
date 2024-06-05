//
//  GXPublishEventSignUserCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/18.
//

import UIKit
import Reusable
import RxSwift

class GXPublishEventSignUserCell: UITableViewCell, NibReusable {
    private var disposeBag = DisposeBag()
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    var model: GXPublishEventsignsData?

    var avatarAction: GXActionBlockItem<GXPublishEventSignUserCell>?
    var senderAction: GXActionBlockItem<GXPublishEventSignUserCell>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.text = nil
        self.avatarButton.setBackgroundImage(.defaultAvatar, for: .normal)
        self.sendButton.setBackgroundColor(.gx_green, for: .normal)
        self.sendButton.setBackgroundColor(.gx_lightGray, for: .disabled)
        self.sendButton.setTitle("发消息", for: .normal)
        self.sendButton.setTitle("已发送", for: .disabled)

        self.textField.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.textField.markedTextRange == nil else { return }
            guard var text = self.textField.text else { return }
            let maxCount: Int = 15
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.textField.text = text
            }
            self.model?.eventReward = text
        }).disposed(by: disposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.nameLabel.text = nil
        self.avatarButton.setBackgroundImage(.defaultAvatar, for: .normal)
        self.textField.text = nil
    }

    func bindCell(model: GXPublishEventsignsData?) {
        guard let data = model else { return }

        self.model = data;
        if let avatarPic = data.avatarPic {
            self.avatarButton.kf.setImage(with: URL(string: avatarPic), for: .normal, placeholder: UIImage.gx_defaultAvatar)
        } else {
            self.avatarButton.setBackgroundImage(.defaultAvatar, for: .normal)
        }
        self.nameLabel.text = data.nickName
        self.textField.text = data.eventReward
        if (data.pushMessageFlag ?? false) {
            self.textField.isUserInteractionEnabled = false
            self.sendButton.isEnabled = false
        } else {
            self.textField.isUserInteractionEnabled = true
            self.sendButton.isEnabled = true
        }
        self.sendButton.isHidden = data.eventReward?.isEmpty ?? true
    }

}

extension GXPublishEventSignUserCell {

    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        self.avatarAction?(self)
    }

    @IBAction func sendButtonClicked(_ sender: UIButton) {
        guard self.textField.text?.count ?? 0 > 0 else {
            GXToast.showError(text: "消息不能为空")
            return
        }
        let title = "推送用户奖励信息吗？"
        GXUtil.showAlert(title: title, actionTitle: "确定") { alert, index in
            guard index == 1 else { return }
            self.senderAction?(self)
        }
    }

}
