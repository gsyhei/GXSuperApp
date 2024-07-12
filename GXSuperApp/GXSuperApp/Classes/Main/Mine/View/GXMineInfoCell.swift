//
//  GXMineInfoCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import Reusable
import HXPhotoPicker

class GXMineInfoCell: UITableViewCell, NibReusable {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var avatarIView: UIImageView!
    @IBOutlet weak var vipIView: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    private var action: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXUserData?, action: GXActionBlock?) {
        self.action = action
        guard let model = model else { return }
        self.avatarIView.kf.setImage(with: URL(string: model.photo))
        if model.memberFlag == GX_YES {
            self.vipIView.image = UIImage(named: "my_top_ic_vip_normal")
            let colors: [UIColor] = [UIColor(hexString: "#FFF8B5"), UIColor(hexString: "#E8AA63")]
            let image = UIImage(gradientColors: colors, style: .horizontal)
            self.avatarButton.setBackgroundImage(image, for: .normal)
        }
        else {
            self.vipIView.image = UIImage(named: "my_top_ic_vip_disable")
            let colors: [UIColor] = [.white, UIColor(hexString: "#DCDCDC")]
            let image = UIImage(gradientColors: colors, style: .horizontal)
            self.avatarButton.setBackgroundImage(image, for: .normal)
        }
        if model.phoneNumber.count > 6 {
            let count = (model.phoneNumber.count - 4)/2
            let beginCount = model.phoneNumber.count - count - 4
            let beginText = model.phoneNumber.substring(to: beginCount)
            let endText = model.phoneNumber.substring(from: beginCount + 4)
            self.phoneLabel.text = beginText + "****" + endText
        }
        else {
            self.phoneLabel.text = "****"
        }
    }
    
}

private extension GXMineInfoCell {
    
    @IBAction func avatarButtonClicked(_ sender: UIButton) {
        self.action?()
    }
    
    func showPickerAvatar() {
        guard let image = self.avatarButton.image(for: .normal) else { return }
        HXPhotoPicker.PhotoBrowser.show(pageIndex: 0, transitionalImage: image) {
            return 1
        } assetForIndex: {_ in
            return PhotoAsset(localImageAsset: LocalImageAsset(image: image))
        } transitionAnimator: { index, arg  in
            return self.avatarButton
        }
    }
    
}
