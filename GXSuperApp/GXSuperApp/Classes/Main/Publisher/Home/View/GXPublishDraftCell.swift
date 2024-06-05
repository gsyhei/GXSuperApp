//
//  GXPublishActivityCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit
import Reusable

class GXPublishDraftCell: UITableViewCell, NibReusable {
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var activityAddressLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    var deleteAction: GXActionBlockItem<GXPublishDraftCell>?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        self.deleteAction?(self)
    }

    func bindModel(model: GXActivityBaseInfoData) {
        let imageUrlArr = model.listPics.components(separatedBy: ",")
        if let imageUrlStr = imageUrlArr.first, imageUrlStr.count > 0 {
            self.activityImageView.kf.setImage(with: URL(string: imageUrlStr), placeholder: UIImage.gx_defaultActivityIcon)
        } else {
            self.activityImageView.kf.setImage(with: URL(string: model.listPics), placeholder: UIImage.gx_defaultActivityIcon)
        }
        self.activityNameLabel.text = model.activityName
        self.activityDateLabel.text = model.startToEndDateString()
        self.activityAddressLabel.text = model.showCityName()
    }

}

