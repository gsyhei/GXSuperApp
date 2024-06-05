//
//  GXPublishQuestionnaireOptionCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/20.
//

import UIKit
import Reusable

class GXPublishQuestionnaireOptionCell: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    private var isDetail: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if self.isDetail {
            self.containerView.backgroundColor = selected ? .gx_green:.gx_background
        }
        else {
            self.containerView.backgroundColor = selected ? .gx_green:.white
        }
    }

    func bindCell(model: GXQuestionairetopicoptionsModel?, isDetail: Bool = false) {
        self.isDetail = isDetail
        if isDetail {
            self.contentView.backgroundColor = .white
            self.containerView.backgroundColor = .gx_background
        }
        else {
            self.contentView.backgroundColor = .gx_background
            self.containerView.backgroundColor = .white
        }
        self.titleLabel.text = model?.optionTitle
    }

}
