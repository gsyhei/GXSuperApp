//
//  GXPublishLocationCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/18.
//

import UIKit
import Reusable

class GXPublishLocationCell: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.nameLabel.text = nil
        self.contentLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(model: GXPoisModel?) {
        guard let model = model else { return }

        self.nameLabel.text = model.name
        let adminNames: String = model.province + model.city
        self.contentLabel.text = adminNames + " " + model.address
    }
    
    func bindCountCell(model: GXPrioritycitysModel?) {
        guard let model = model else { return }

        self.nameLabel.text = model.adminName
        self.contentLabel.text = "包含搜索结果 \(model.count) 条"
    }
}
