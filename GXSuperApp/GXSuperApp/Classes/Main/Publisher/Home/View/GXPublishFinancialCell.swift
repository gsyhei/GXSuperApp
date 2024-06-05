//
//  GXPublishFinancialCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit
import Reusable

class GXPublishFinancialCell: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.numberLabel.text = nil
        self.unitPriceLabel.text = nil
        self.totalPriceLabel.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXActivityfinancesListItem?) {
        guard let item = model else { return }

        self.nameLabel.text = item.materialName
        self.numberLabel.text = "\(item.quantity)"
        self.unitPriceLabel.text = String(format: "%.2f", item.unitPrice)
        self.totalPriceLabel.text = String(format: "%.2f", item.totalPrice)
    }

}
