//
//  GXHomeSearchResultCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/17.
//

import UIKit
import Reusable
import GooglePlaces

class GXHomeSearchResultCell: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.infoLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.text = nil
        self.infoLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GMSPlace) {
        self.nameLabel.text = model.name
        self.infoLabel.text = model.formattedAddress
    }
    
}
