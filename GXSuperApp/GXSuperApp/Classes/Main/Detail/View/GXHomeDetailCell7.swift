//
//  GXHomeDetailCell7.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit
import Reusable

class GXHomeDetailCell7: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var arrowIView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard !self.arrowIView.isHidden else { return }
        self.containerView.backgroundColor = highlighted ? .gx_lightGray : .white
    }
    
    func setCellType(name: String, info: String? = nil, isSelection: Bool) {
        self.nameLabel.text = name
        self.infoLabel.text = info
        self.arrowIView.isHidden = !isSelection
    }
    
    func setCell7Type(model: GXStationConsumerDetailData?) {
        guard let model = model else { return }
        self.nameLabel.text = "Partner"
        self.infoLabel.text = model.companyName
        self.arrowIView.isHidden = true
    }
    
    func setCell7FeedbackType() {
        self.nameLabel.text = "Feedback"
        self.infoLabel.text = nil
        self.arrowIView.isHidden = false
    }
    
}
