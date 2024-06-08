//
//  GXHomeMarkerCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/8.
//

import UIKit
import Reusable

class GXHomeMarkerCell: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.containerView.backgroundColor = highlighted ? .gx_lightGray : .white
    }
    
}
